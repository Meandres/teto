{
	description = "Teto configuration";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		nixvim = {
			url = "github:nix-community/nixvim";
		};
		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nur.url = "github:nix-community/NUR";
		agenix = {
			url = "github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
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
		, agenix
		, flake-parts
		, devshell
		, ...
	}:
	flake-parts.lib.mkFlake { inherit inputs; }
	( top@{config, withSystem, moduleWithSystem, ...}:
	let
		hosts = {
			teto  = { username = "meandres"; profile = "desktop"; };
			ohmu  = { username = "ilya";     profile = "desktop"; };
			mehve = { username = "ilya";     profile = "server";  };
		};
		mkHost = hostname: { username, profile }:
			let
				systemModule   = if profile == "server" then ./modules/server.nix else ./modules/configuration.nix;
				homeModuleFile = if profile == "server" then ./modules/home-server.nix else ./modules/home.nix;
			in
			nixpkgs.lib.nixosSystem {
				specialArgs = {
					inherit username;
					inherit hostname;
					inherit nixvim;
				};
				modules = [
					{ nixpkgs.overlays = [ nur.overlays.default ]; }
					agenix.nixosModules.default
					./hosts/${hostname}
					systemModule
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.sharedModules = [
							nixvim.homeModules.nixvim
						];
						home-manager.users."${username}" = import homeModuleFile;
						home-manager.extraSpecialArgs = { inherit username; };
					}
				];
			};
		installer = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [ ./installer/iso.nix ];
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
			nixosConfigurations = (nixpkgs.lib.mapAttrs mkHost hosts) // {
				inherit installer;
			};
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
					agenix.packages.${pkgs.system}.default
				];
			};
		};
  });
}
