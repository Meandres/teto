{ config, pkgs, flakepkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
			./pkgs.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "teto";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services = {
		displayManager = {
			defaultSession = "none+i3";
		};
    xserver = {
		  enable = true;
		  desktopManager = { xterm.enable = false; };
		  windowManager.i3 = {
			  enable = true;
			  extraPackages = with pkgs; [
				  dmenu
				  i3status
				  i3lock
				  i3blocks
			  ];
		  };
		  xkb = {
    	  layout = "fr";
    	  variant = "azerty";
		  };
	  };
  };

	users.groups.meandres = {};
	users.users.meandres = {
		isNormalUser = true;
		group = "meandres";
		extraGroups = [ "wheel" "networkmanager" ];
	};

  console.keyMap = "fr";
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Install firefox.
  nixpkgs.config.allowUnfree = true;


  system.stateVersion = "24.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
