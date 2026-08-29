{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "Iosevka Nerd Font Mono";
        size = 10.0;
      };
      window = {
        padding = { x = 6; y = 6; };
        decorations = "none";
      };
      colors = {
        primary = {
          background = "#1F1F1F";
          foreground = "#FFFFFF";
        };
      };
    };
  };
}
