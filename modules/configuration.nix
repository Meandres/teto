{ config, pkgs, username, hostname, ... }:
{
  imports = [
    ./base.nix
    ./pkgs.nix
  ];

  # btusb re-enables autosuspend after udev runs; disable it at the module level.
  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

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

  environment.pathsToLink = [ "/libexec" ];
  users.users.${username}.extraGroups = [ "networkmanager" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Enable experimental features for better codec support (AAC, LDAC, aptX)
        Experimental = true;
        # Keep A2DP (stereo music) profile — prevents downgrade to mono HFP
        MultiProfile = "multiple";
      };
    };
  };
  services.blueman.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint hplip brlaser cnijfilter2 ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      extraConfig = {
        # Prefer higher-quality codecs; increase BT buffer to reduce crackling
        "bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = false;
          };
        };
        "bluetooth-properties" = {
          "monitor.bluez.properties" = {
            # Disable SBC-XQ: its larger packets (bitpool 76, ~617 bytes) are
            # more sensitive to the brief RF errors visible in the LQ reading.
            # Standard SBC (bitpool 53, ~420 bytes) is smaller and survives
            # the same interference without audible crackling.
            "bluez5.enable-sbc-xq" = false;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.codecs" = [ "sbc" ];
          };
        };
      };
    };
  };

  programs.nix-ld.enable = true;

  services.udisks2.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Disable USB autosuspend for the Intel Bluetooth adapter.
  # Without this, the adapter sleeps after 2s of silence and the wake-up
  # causes audible crackling on the Bose SoundLink.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="8087", ATTRS{idProduct}=="0026", ATTR{power/control}="on"
  '';
}
