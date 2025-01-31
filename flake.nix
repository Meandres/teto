{
	description = "Teto configuration";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
		nixvim-pkg = {
			url = "github:nix-community/nixvim";
			follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
  };

	outputs = { 
		self, 
		nixpkgs,
		nixvim-pkg,
		home-manager,
		flake-utils,
		... 
	}@ inputs : (flake-utils.lib.eachSystem ["x86_64-linux"] (system:
		let
			pkgs = nixpkgs.legacyPackages.${system};
			nixvim = nixvim-pkg.legacyPackages.${system};
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
		})) // (let
				pkgs = nixpkgs.legacyPackages.x86_64-linux;
				nixvim = nixvim-pkg.legacyPackages.x86_64-linux;
			in {
			homeConfigurations = {
				ilya = home-manager.lib.homeManagerConfiguration {
					inherit pkgs;
					modules = [ ./modules/standalone-home.nix ];
					extraSpecialArgs = {
						username = "ilya";
					};
				};
			};
		}
	);
}
