{
	description = "Teto configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
  };

	outputs = { 
		self, 
		nixpkgs,
		home-manager,
		flake-utils,
		... 
	}@ inputs : 
		let
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfree = true;
				overlays = [];
			};
			system = "x86_64-linux";
		in {
			nixosConfigurations = {
				teto = inputs.nixpkgs.lib.nixosSystem {
					modules = [ 
						./modules/configuration.nix 
						home-manager.nixosModules.home-manager {
							home-manager.useGlobalPkgs = true;
							home-manager.useUserPackages = true;
							home-manager.backupFileExtension = "hm-backup";
							home-manager.users.meandres = import ./modules/home.nix;
						}
					];
				};
			};
		};
}
