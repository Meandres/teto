{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		# shell things
    vim
		alacritty
		ack
		git
		htop
    mons
		just
		claude-code

		# internet
		firefox
		thunderbird

		# files
		nemo

		# messaging
		discord
		slack
		
		# multimedia
		vlc
		spotify	

    #settings
    lightdm
    pavucontrol
		arandr
		flameshot
		clipmenu
  ];
}
