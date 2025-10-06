{ pkgs, ... } : 
let 
  background = "#282A2E";
  background-alt = "#373B41";
  foreground = "#C5C8C6";
  primary = "#F0C674";
  secondary = "#8ABEB7";
  disabled = "#707880";
  black = "#263238";
  white = "#D8DEE9";
  red = "#BF616A";
  red1 = "#BF3B48";
  green = "#94AD7D";
  green1 = "#70AD37";
  blue = "#5E81AC";
  blue1 = "#3C6EAC";
  cyan = "#7AACBA";
  cyan1 = "#56A4BA";
  violet = "#B48EAD";
  violet1 = "#B46AA6";
  orange = "#D08770";
  orange1 = "#D06847";
  yellow = "#CFB074";
  yellow1 = "#CF9B36";
  focus = "#8C8C8C";
  focus1 = "#757575";
  unfocus = "#1A2328";
  unfocus1 = "#101010";
in
{
  services.polybar = {
    enable = true;
    package = pkgs.polybarFull; 
    script = ''
      sudo kill -9 $(pidof polybar)
      for m in $(polybar -M | ${pkgs.coreutils}/bin/cut -d":" -f1); do
        export MONITOR="$m"
        polybar bottom &
      done
    '';
    #for m in $(polybar -M | cut -d':' -f1); do done
    config = {
      "bar/bottom" = {
        monitor = "\${env:MONITOR}";
        width = "100%";
        height = "3%";
        radius = 0;
        bottom = true;
        override-redirect = false;
        #wm-restack = "i3";

        background = "${background}";
        foreground = "${foreground}";
        line-size = "3pt";
        border-size = "4pt";
        boder-color = "#00000000";
        padding-left = 0;
        padding-right = 1;
        module-margin = 1;

        font = ["Noto Sans: size=11;1"];
        separator = "|";
        separator-foreground = "${disabled}";
        enable-ipc = true;

        modules-left = "i3";
        modules-right = "pulseaudio wlan date";
      };
      
      "module/i3" = {
        type = "internal/i3";
        index-sort = true;

        label-mode-padding = 2;
        label-mode-foreground = "#000";
        label-mode-background = "${focus}";

        #focused = Active workspace on focused monitor
        label-focused = "%index%";
        label-focused-background = "${focus}";
        label-focused-foreground = "${black}";
        label-focused-underline = "${focus1}";
        label-focused-padding = 2;

        # unfocused = Inactive workspace on any monitor
        label-unfocused = "%index%";
        label-unfocused-padding = 2;
        label-unfocused-background = "${unfocus}";
        label-unfocused-underline= "${unfocus1}";

        # visible = Active workspace on unfocused monitor
        label-visible = "%index%";
        label-visible-background = "<label-focused-background>";
        label-visible-underline = "<label-focused-underline>";
        label-visible-padding = "<label-focused-padding>";

        # urgent = Workspace with urgency hint set
        label-urgent = "%index%";
        label-urgent-background = "#5f5f5f";
        label-urgent-padding = 2;

      };

      "module/pulseaudio" = {      
        type = "internal/pulseaudio";

        format-volume-prefix = "VOL ";
        format-volume-prefix-foreground = "${primary}";
        format-volume = "<label-volume>";

        label-volume = "%percentage%%";

        label-muted = "muted";
        label-muted-foreground = "${disabled}";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = "RAM ";
        format-prefix-foreground = "${primary}";
        label = "%percentage:2%%";
      };

      "module/wlan" = {
        type = "internal/network";
        interval = 5;
        format-connected = "<label-connected>";
        format-disconnected = "<label-disconnected>";
        label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
        interface-type = "wireless";
        label-connected = "%essid%";
      };

      #"module/eth" = {
      #  inherit = "network-base";
      #  interface-type = "wired";
      #  label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
      #};

      "module/date" = {
        type = "internal/date";
        interval = 1;

        date = "%H:%M:%S %Y-%m-%d";

        label = "%date%";
        label-foreground = "${primary}";
      };

      "settings" = {
        screenchange-reload = true;
      };
    };
  };
}
