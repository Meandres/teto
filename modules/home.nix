{ config, pkgs, username, nixvim, ... }:
{    
	imports = [
		./home-config/i3.nix
		./home-config/vim.nix
		# ./home-config/polybar.nix
		./home-config/i3bar.nix
		./home-config/rofi.nix
		./home-config/firefox.nix
		./home-config/alacritty.nix
	];
	home = {
		username = "${username}";
		homeDirectory = "/home/${username}";
		stateVersion = "25.05";
	};

	xdg.userDirs = {
		enable = true;
		createDirectories = false;
		desktop     = "$HOME";
		documents   = "$HOME";
		download    = "$HOME";
		music       = "$HOME";
		pictures    = "$HOME";
		publicShare = "$HOME";
		templates   = "$HOME";
		videos      = "$HOME";
	};
	#xdg.cacheHome = "/scratch/${username}/.cache";
	#xdg.stateHome = "/scratch/${username}/.local/share";

	programs.vscode = {
		enable = true;
		profiles.default.extensions = with pkgs.vscode-extensions; [
			anthropic.claude-code
			jnoortheen.nix-ide
			tomoki1207.pdf
			github.vscode-pull-request-github
			mechatroner.rainbow-csv
		];
	};

	services.picom.enable = true;

	programs.home-manager.enable = true;
	programs.git = {
		enable = true;
		settings.user = {
			name = "Meandres";
			email = "ilya.meignan-masson@mailoo.org";
		};
	};
	programs.bash = {
		enable = true;
		enableCompletion = true;
	};
	services.udiskie = {
		enable = true;
		tray = "auto";
	};
}
