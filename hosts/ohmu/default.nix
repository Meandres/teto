{ ... }:

{
  imports = [
    ../../modules/configuration.nix
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";
}
