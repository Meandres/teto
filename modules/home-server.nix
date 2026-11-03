{ pkgs, username, ... }:
{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  home.packages = with pkgs; [
    tmux
    htop
    ripgrep
    fd
  ];

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Meandres";
      email = "ilya.meignan-masson@mailoo.org";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    mouse = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*.dos.cit.tum.de" = {
        user = username;
        identityFile = "~/.ssh/id_ed25519_r";
        identitiesOnly = true;
      };
    };
  };
}
