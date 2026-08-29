{ pkgs, ... }:
{
  home.packages = with pkgs; [ papirus-icon-theme ];

  programs.rofi = {
    enable = true;
    font = "Iosevka Nerd Font Mono 11";
    theme = ./rofi/launcher.rasi;
    extraConfig = {
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
