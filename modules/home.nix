{ config, pkgs, lib, i3exit-bin, ... } : {

		imports = [
			./home-config/i3.nix
			./home-config/vim.nix
			#./home-config/polybar.nix
			#./home-config/alacritty.nix
		];

		home = {
			username = "meandres";
			homeDirectory = lib.mkDefault "/home/meandres";
			stateVersion = "24.05";
		};

		programs = {
			home-manager.enable = true;
			git = {
				enable = true;
				userName = "Meandres";
				userEmail = "ilya.meignan-masson@mailoo.org";
			};
			bash.enable = true;
		};
}
