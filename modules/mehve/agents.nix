{ config, lib, pkgs, username, ... }:
let
  home       = "/home/${username}";
  scratch    = "${home}/agent-runs";
  db         = "${scratch}/agent-log.sqlite";
  skillsDir  = "${home}/.claude/skills";

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    python-telegram-bot
    requests
  ]);

  agentRun = pkgs.writeShellApplication {
    name = "agent-run";
    runtimeInputs = with pkgs; [ claude-code jq sqlite coreutils ];
    text = builtins.readFile ./scripts/agent-run.sh;
  };

  telegramBot = pkgs.writers.writePython3Bin "mehve-telegram-bot"
    { libraries = [ pkgs.python3Packages.python-telegram-bot ]; flakeIgnore = [ "E265" "E501" "W503" ]; }
    (builtins.readFile ./scripts/telegram-bot.py);

  prReview = pkgs.writers.writePython3Bin "mehve-pr-review"
    { libraries = [ pkgs.python3Packages.requests ]; flakeIgnore = [ "E265" "E501" ]; }
    (builtins.readFile ./scripts/pr-review.py);

  # Topic + user IDs — public, not sensitive on their own.
  cfg = {
    allowedUser = "1793393622";
    groupId     = "-1004334770180";
    prTopicId   = "2";
    repos       = "miniosv/miniosv";
  };
in
{
  environment.systemPackages = with pkgs; [
    claude-code
    gh
    inotify-tools
    direnv
    nix-direnv
    jq
    yq-go
    sqlite
    agentRun
    telegramBot
    prReview
    pythonEnv
  ];

  # Agenix secrets, decrypted at activation and exposed to the user's systemd services.
  age.secrets.telegram_bot_token = {
    file  = ../../secrets/telegram_bot_token.age;
    owner = username;
    group = username;
    mode  = "0400";
  };
  age.secrets.github_token = {
    file  = ../../secrets/github_token.age;
    owner = username;
    group = username;
    mode  = "0400";
  };

  # Create the agent-runs tree + sqlite schema at boot.
  systemd.tmpfiles.rules = [
    "d ${scratch} 0755 ${username} ${username} -"
    "d ${scratch}/interactive 0755 ${username} ${username} -"
    "d ${scratch}/pr-review 0755 ${username} ${username} -"
    "d ${skillsDir} 0755 ${username} ${username} -"
  ];

  systemd.services.mehve-agent-db-init = {
    description = "Initialise the mehve agent-log sqlite DB";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = username;
    };
    script = ''
      ${pkgs.sqlite}/bin/sqlite3 ${db} <<'SQL'
      CREATE TABLE IF NOT EXISTS runs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task TEXT NOT NULL,
        started_at TEXT NOT NULL,
        finished_at TEXT,
        input_tokens INTEGER,
        output_tokens INTEGER,
        cache_read_tokens INTEGER,
        cost_usd REAL,
        status TEXT,
        notes TEXT
      );
      CREATE INDEX IF NOT EXISTS idx_runs_task ON runs(task);
      CREATE INDEX IF NOT EXISTS idx_runs_started ON runs(started_at);
      SQL
    '';
  };

  # Telegram bot — one process, systemd-managed, restarts on failure.
  systemd.services.mehve-telegram-bot = {
    description = "mehve Telegram control bot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "mehve-agent-db-init.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      User = username;
      Group = username;
      Restart = "on-failure";
      RestartSec = 10;
      WorkingDirectory = home;
      LoadCredential = [
        "telegram_bot_token:${config.age.secrets.telegram_bot_token.path}"
      ];
      Environment = [
        "AGENT_DB=${db}"
        "AGENT_SCRATCH_ROOT=${scratch}/interactive"
        "AGENT_RUN_SCRIPT=${agentRun}/bin/agent-run"
        "SKILLS_DIR=${skillsDir}"
        "MAX_CONCURRENT=3"
        "MESSAGE_SPLIT_CHARS=3800"
        "AGENT_TIMEOUT=1800"
        "AGENT_COST_CAP=2.0"
        "TELEGRAM_ALLOWED_USER=${cfg.allowedUser}"
        "TELEGRAM_GROUP_ID=${cfg.groupId}"
      ];
      ExecStart = pkgs.writeShellScript "mehve-bot-launcher" ''
        export TELEGRAM_BOT_TOKEN=$(cat ''${CREDENTIALS_DIRECTORY}/telegram_bot_token)
        exec ${telegramBot}/bin/mehve-telegram-bot
      '';
    };
  };

  # Daily PR-review job at 08:00 Europe/Berlin.
  systemd.timers.mehve-pr-review = {
    description = "Daily PR review poll";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 08:00:00";
      Persistent = true;
      Unit = "mehve-pr-review.service";
    };
  };
  systemd.services.mehve-pr-review = {
    description = "Scan watched repos for new PRs and review them";
    serviceConfig = {
      Type = "oneshot";
      User = username;
      Group = username;
      WorkingDirectory = home;
      LoadCredential = [
        "github_token:${config.age.secrets.github_token.path}"
        "telegram_bot_token:${config.age.secrets.telegram_bot_token.path}"
      ];
      Environment = [
        "AGENT_DB=${db}"
        "AGENT_SCRATCH_ROOT=${scratch}"
        "AGENT_RUN_SCRIPT=${agentRun}/bin/agent-run"
        "REVIEW_REPOS=${cfg.repos}"
        "TELEGRAM_GROUP_ID=${cfg.groupId}"
        "TELEGRAM_PR_TOPIC_ID=${cfg.prTopicId}"
      ];
      ExecStart = pkgs.writeShellScript "mehve-pr-review-launcher" ''
        export GH_TOKEN=$(cat ''${CREDENTIALS_DIRECTORY}/github_token)
        export TELEGRAM_BOT_TOKEN=$(cat ''${CREDENTIALS_DIRECTORY}/telegram_bot_token)
        exec ${prReview}/bin/mehve-pr-review
      '';
    };
  };

  # Server timezone for the systemd calendar event.
  time.timeZone = lib.mkForce "Europe/Berlin";
}
