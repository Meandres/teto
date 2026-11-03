{ pkgs, ... }:
let
  bg     = "#1F1F1F";
  fg     = "#FFFFFF";
  fg-alt = "#707070";
  accent = "#e53935";
  clipman = "${pkgs.xfce4-clipman-plugin}/bin/xfce4-clipman-history";
in
{
  home.packages = with pkgs; [
    xfce4-clipman-plugin
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
  ];

  systemd.user.services.xfce4-clipman = {
    Unit.Description = "Xfce4 Clipman clipboard manager";
    Service = {
      ExecStart = "${pkgs.xfce4-clipman-plugin}/bin/xfce4-clipman";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.i3status-rust = {
    enable = true;
    bars.bottom = {
      icons = "awesome6";
      theme = "plain";
      settings.theme.overrides = {
        idle_bg             = bg;
        idle_fg             = fg;
        good_bg             = bg;
        good_fg             = fg;
        warning_bg          = bg;
        warning_fg          = fg-alt;
        critical_bg         = accent;
        critical_fg         = fg;
        separator_bg        = bg;
        separator_fg        = fg-alt;
        alternating_tint_bg = bg;
        alternating_tint_fg = fg;
      };
      blocks = [
        {
          block = "custom";
          command = "echo ' clipboard '";
          interval = 3600;
          click = [{ button = "left"; cmd = "${clipman}"; }];
        }
        {
          block = "sound";
          format = " $icon {$volume|'muted'} ";
        }
        {
          block = "net";
          device = "eno1";
          format = " {$device|'offline'} ";
          interval = 5;
        }
        {
          block = "cpu";
          interval = 1;
          format = " $barchart ";
        }
        {
          block = "memory";
          format = " $icon $mem_used ";
          interval = 2;
        }
        {
          block = "time";
          interval = 1;
          format = " $icon $timestamp.datetime(f:'%H:%M') ";
        }
        #{
        #  block = "custom";
        #  command = "echo ' ⏻ '";
        #  interval = 3600;
        #  click = [{ button = "left"; cmd = "bash -c 'r=$(printf \"Lock\\nSuspend\\nReboot\\nShutdown\" | ${rofi} -dmenu -p ⏻); case \"$r\" in (Lock) ${i3lock};; (Suspend) systemctl suspend;; (Reboot) systemctl reboot;; (Shutdown) systemctl poweroff;; esac'"; }];
        #}
      ];
    };
  };

  xsession.windowManager.i3.config.bars = [{
    position = "bottom";
    statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
    trayOutput = "primary";
    fonts = {
      names = [ "Iosevka Nerd Font Mono" "Symbols Nerd Font Mono" ];
      size = 12.0;
    };
    colors = {
      background        = bg;
      statusline        = fg;
      separator         = fg-alt;
      focusedWorkspace  = { border = accent; background = accent; text = fg; };
      activeWorkspace   = { border = bg;     background = bg;     text = fg-alt; };
      inactiveWorkspace = { border = bg;     background = bg;     text = fg-alt; };
      urgentWorkspace   = { border = accent; background = accent; text = fg; };
    };
  }];
}
