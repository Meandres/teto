{ pkgs, ... }:
let
	notion-electron-fixed = pkgs.symlinkJoin {
		name = "notion-electron-fixed";
		paths = [ pkgs.notion-electron ];
		nativeBuildInputs = [ pkgs.makeWrapper ];
		postBuild = ''
			wrapProgram $out/bin/notion-electron \
				--prefix LD_LIBRARY_PATH : ${pkgs.stdenv.cc.cc.lib}/lib
		'';
	};
in
{
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
		zulip

		# productivity
		notion-electron-fixed
		
		# multimedia
		vlc
    deezer-desktop

    #settings
    lightdm
    pavucontrol
		arandr
		xfce.xfce4-screenshooter
		clipmenu
  ];
}
