{ pkgs, modulesPath, ... }:
let
  pubkeys = import ../modules/pubkeys.nix;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  networking.hostName = "mehve-installer";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  users.users.root.openssh.authorizedKeys.keys = [ pubkeys.L ];
  users.users.nixos.openssh.authorizedKeys.keys = [ pubkeys.L ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    vim
    tmux
    parted
    gptfdisk
    rsync
    curl
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
}
