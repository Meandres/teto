{ pkgs, username, ... }:
let
  pubkeys = import ./pubkeys.nix;
in
{
  imports = [ ./base.nix ];

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = pubkeys.users;
  users.users.root.openssh.authorizedKeys.keys = [];

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
      overalljails = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [];
  };

  services.chrony.enable = true;

  programs.bash.completion.enable = true;

  security.sudo.wheelNeedsPassword = true;
}
