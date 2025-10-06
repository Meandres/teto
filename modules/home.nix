{ config, pkgs, username, nixvim, ... }:
{    
	imports = [
		./home-config/i3.nix
		./home-config/vim.nix
		./home-config/polybar.nix
		#./home-config/alacritty.nix
	];
	home = {
		username = "${username}";
		homeDirectory = "/home/${username}";
		stateVersion = "25.05";
	};
	xdg.enable = true;
	#xdg.cacheHome = "/scratch/${username}/.cache";
	#xdg.stateHome = "/scratch/${username}/.local/share";

	programs.home-manager.enable = true;
	programs.git = {
		enable = true;
		userName = "Meandres";
		userEmail = "ilya.meignan-masson@mailoo.org";
	};
	programs.bash = {
		enable = true;
		enableCompletion = true;
	};
}
