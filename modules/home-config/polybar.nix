{ pkgs, ... }:
let
  bg     = "#1F1F1F";
  fg     = "#FFFFFF";
  fg-alt = "#707070";
  accent = "#e53935";

  glyph = cp: builtins.fromJSON "\"\\u${cp}\"";
  iVolOff  = glyph "F026";
  iVolDown = glyph "F027";
  iVolUp   = glyph "F028";
  iWifi    = glyph "F1EB";
  iCpu     = glyph "F0E4";
  iMem     = glyph "F1C0";
  iClock   = glyph "F017";
  iClip    = glyph "F0EA";
in
{
  home.packages = with pkgs; [ nerd-fonts.iosevka nerd-fonts.symbols-only ];

  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    script = ''
      killall -q polybar || true
      sleep 2
      PRIMARY=$(polybar -M | ${pkgs.gnugrep}/bin/grep '(primary)' | ${pkgs.coreutils}/bin/cut -d':' -f1)
      for m in $(polybar -M | ${pkgs.coreutils}/bin/cut -d':' -f1); do
        if [ "$m" = "$PRIMARY" ]; then
          MONITOR=$m polybar primary &
        else
          MONITOR=$m polybar main &
        fi
      done
    '';
    config = {
      "bar/main" = {
        monitor = "\${env:MONITOR}";
        bottom = true;
        fixed-center = true;
        width = "98%";
        height = 40;
        offset-x = "1%";
        offset-y = 4;

        background = bg;
        foreground = fg;

        line-size = 2;
        border-bottom-size = 2;
        border-bottom-color = accent;

        padding-left = 1;
        padding-right = 1;
        module-margin-left = 1;
        module-margin-right = 1;

        font-0 = "Iosevka Nerd Font Mono:size=11;3";
        font-1 = "Symbols Nerd Font Mono:size=11;3";

        modules-left = "launcher i3";
        modules-center = "date";
        modules-right = "clipboard pulseaudio wlan cpu memory sysmenu";

        enable-ipc = true;
      };

      "bar/primary" = {
        "inherit" = "bar/main";
        modules-right = "clipboard pulseaudio wlan cpu memory sysmenu tray";
      };

      "module/launcher" = {
        type = "custom/text";
        format = " ☰ ";
        format-background = accent;
        format-foreground = fg;
        format-padding = 1;
        click-left = "${pkgs.rofi}/bin/rofi -show drun -modi drun &";
      };

      "module/i3" = {
        type = "internal/i3";
        index-sort = true;
        pin-workspaces = true;

        label-mode-padding = 2;
        label-mode-foreground = fg;
        label-mode-background = accent;

        label-focused = "%index%";
        label-focused-foreground = accent;
        label-focused-overline = accent;
        label-focused-padding = 3;

        label-unfocused = "%index%";
        label-unfocused-foreground = fg-alt;
        label-unfocused-padding = 3;

        label-visible = "%index%";
        label-visible-foreground = fg-alt;
        label-visible-padding = 3;

        label-urgent = "%index%";
        label-urgent-foreground = fg;
        label-urgent-background = accent;
        label-urgent-padding = 3;
      };

      "module/clipboard" = {
        type = "custom/text";
        format = " %{T2}${iClip}%{T-} ";
        format-foreground = fg-alt;
        format-padding = 1;
        click-left = "env PATH=${pkgs.rofi}/bin:$PATH CM_LAUNCHER=rofi ${pkgs.clipmenu}/bin/clipmenu &";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        use-ui-max = false;
        interval = 5;

        format-volume = "%{T2}<ramp-volume>%{T-} <label-volume>";
        ramp-volume-0 = "${iVolOff}";
        ramp-volume-1 = "${iVolDown}";
        ramp-volume-2 = "${iVolUp}";

        format-muted = "%{T2}${iVolOff}%{T-} muted";
        format-muted-foreground = fg-alt;

        label-volume = "%percentage%%";
      };

      "module/wlan" = {
        type = "internal/network";
        interface-type = "wireless";
        interval = 5;

        format-connected = "%{T2}${iWifi}%{T-} <label-connected>";
        label-connected = "%essid%";

        format-disconnected = "%{T2}${iWifi}%{T-} offline";
        format-disconnected-foreground = fg-alt;
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 1;
        format = "%{T2}${iCpu}%{T-} <label>";
        label = "%percentage%%";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format = "%{T2}${iMem}%{T-} <label>";
        label = "%mb_used%";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        time = "%{T2}${iClock}%{T-} %H:%M";
        time-alt = "%a, %d %b %Y";
        format = "<label>";
        label = "%time%";
      };

      "module/tray" = {
        type = "internal/tray";
        tray-size = "70%";
        tray-padding = 2;
        tray-background = bg;
        hidden = false;
      };

      "module/sysmenu" = {
        type = "custom/text";
        format = " ⏻ ";
        format-background = accent;
        format-foreground = fg;
        format-padding = 1;
        click-left = "bash -c 'r=$(printf \"Lock\\\\nSuspend\\\\nReboot\\\\nShutdown\" | ${pkgs.rofi}/bin/rofi -dmenu -p ⏻); case \"$r\" in (Lock) ${pkgs.i3lock}/bin/i3lock;; (Suspend) systemctl suspend;; (Reboot) systemctl reboot;; (Shutdown) systemctl poweroff;; esac' &";
      };

      "settings" = {
        screenchange-reload = true;
      };
    };
  };
}
