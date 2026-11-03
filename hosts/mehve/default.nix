{ username, lib, ... }:
let
  rKeyFile       = ../../secrets/ssh_r_private.age;
  rKeyExists     = builtins.pathExists rKeyFile;
  tgTokenFile    = ../../secrets/telegram_bot_token.age;
  ghTokenFile    = ../../secrets/github_token.age;
  agentSecretsOk = builtins.pathExists tgTokenFile && builtins.pathExists ghTokenFile;
in
{
  imports = [
    ../../modules/server.nix
    ./hardware-configuration.nix
  ] ++ lib.optional agentSecretsOk ../../modules/mehve/agents.nix;

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # mkIf lets the flake evaluate before the encrypted file is produced.
  age.secrets = lib.mkIf rKeyExists {
    ssh_r_private = {
      file  = rKeyFile;
      path  = "/home/${username}/.ssh/id_ed25519_r";
      owner = username;
      group = username;
      mode  = "0400";
      symlink = false;
    };
  };

  home-manager.users.${username} = import ../../modules/home-server.nix;

  system.stateVersion = "26.05";
}
