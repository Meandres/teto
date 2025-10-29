{
	description = "Teto configuration";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		nixvim = {
			url = "github:nix-community/nixvim";
      		#inputs.nixpkgs.follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
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
		, flake-parts
		, devshell
		, ... 
	}:
	flake-parts.lib.mkFlake { inherit inputs; }
	( top@{config, withSystem, moduleWithSystem, ...}:
	let
		username="meandres";
		hostname="teto";
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
			nixosConfigurations = {
        		teto = nixpkgs.lib.nixosSystem {
          			specialArgs = { 
            			inherit username;
						inherit hostname; 
						inherit nixvim;
          			};
          			modules = [ 
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
				];
			};
		};
  });
}
