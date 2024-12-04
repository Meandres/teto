{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		# shell things
    vim
		alacritty
		ack
		git
		htop

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
  ];
}
