{ config, pkgs, nixvim, lib, username, ... }:
{    
	imports = [
		./home-config/i3.nix
		./home-config/vim.nix
		#./home-config/polybar.nix
		#./home-config/alacritty.nix
	];
	config = {
		home = {
			username = username;
			homeDirectory = "/home/${username}";
			stateVersion = "24.11";
		};
        xdg.cacheHome = "/scratch/${username}/.cache";
        xdg.stateHome = "/scratch/${username}/.local/share";

		programs = {
			home-manager.enable = true;
			git = {
				enable = true;
				userName = "Meandres";
				userEmail = "ilya.meignan-masson@mailoo.org";
			};
			bash.enable = true;
		};
	};
}
