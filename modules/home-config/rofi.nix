{ pkgs, ... }:
{
  home.packages = with pkgs; [ papirus-icon-theme ];

  programs.rofi = {
    enable = true;
    theme = ./rofi/launcher.rasi;
    settings = {
      font               = "Iosevka Nerd Font Mono 11";
      show-icons         = true;
      icon-theme         = "Papirus";
      display-drun       = "";
      drun-display-format = "{name}";
      disable-history    = false;
      hide-scrollbar     = true;
      sidebar-mode       = false;
    };
  };
}
