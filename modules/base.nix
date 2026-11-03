{ pkgs, username, hostname, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = hostname;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  users.groups.${username} = {};
  users.users.${username} = {
    isNormalUser = true;
    group = username;
    extraGroups = [ "wheel" ];
    initialHashedPassword = "";
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tmux
    curl
    wget
    rsync
    jq
  ];
}
