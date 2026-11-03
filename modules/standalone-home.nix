{ config, pkgs, nixvim, username, ... }:
{
	imports = [
		./home-config/vim.nix
		(import ./home-config/ssh.nix "~/.ssh/id_ed25519_r")
	];
	home = {
		username = username;
		homeDirectory = "/home/${username}";
		stateVersion = "24.11";
		packages = with pkgs; [
			ack
			git
			htop
		];
	};
	xdg.enable = true;
  	xdg.cacheHome = "/scratch/${username}/.cache";
  	xdg.stateHome = "/scratch/${username}/.local/share";

	programs = {
		home-manager.enable = true;
		git = {
			enable = true;
			userName = "Meandres";
			userEmail = "ilya.meignan-masson@mailoo.org";
		};
	};
}
