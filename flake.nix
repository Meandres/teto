{
	description = "Teto configuration";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
		nixvim = {
			url = "github:nix-community/nixvim";
      		#inputs.nixpkgs.follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nur.url = "github:nix-community/NUR";
		flake-parts.url = "github:hercules-ci/flake-parts";
    	flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
		devshell.url = "github:numtide/devshell";
  	};

	outputs = inputs@{
		self
		, nixpkgs
		, nixvim
		, home-manager
		, nur
		, flake-parts
		, devshell
		, ...
	}:
	flake-parts.lib.mkFlake { inherit inputs; }
	( top@{config, withSystem, moduleWithSystem, ...}:
	let
		hosts = {
			teto = { username = "meandres"; };
			ohmu = { username = "ilya"; };
		};
		mkHost = hostname: { username }:
			nixpkgs.lib.nixosSystem {
				specialArgs = {
					inherit username;
					inherit hostname;
					inherit nixvim;
				};
				modules = [
					{ nixpkgs.overlays = [ nur.overlays.default ]; }
					./hosts/${hostname}
					./modules/configuration.nix
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.sharedModules = [
							nixvim.homeModules.nixvim
						];
						home-manager.users."${username}" = import ./modules/home.nix;
						home-manager.extraSpecialArgs = { inherit username; };
					}
				];
			};
	in
	{
		systems = [
			"x86_64-linux"
			"aarch64-linux"
		];
		imports = [
			devshell.flakeModule
		];

		flake = {
			nixosConfigurations = nixpkgs.lib.mapAttrs mkHost hosts;
		};
		perSystem = { pkgs, ...}: {
      		legacyPackages.homeConfigurations.ilya = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;
          		modules = [
            		nixvim.homeModules.nixvim
            		./modules/standalone-home.nix
          		];
          		extraSpecialArgs = {
            		username = "ilya";
          		};
        	};
			devshells.default = {
				packages = with pkgs; [
					just
					home-manager
				];
			};
		};
  });
}
