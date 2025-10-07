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
  };

	outputs = { 
		self, 
		nixpkgs,
		nixvim,
		home-manager,
		... 
	}@ inputs: 
		let
      system   = "x86_64-linux";
      pkgs     = nixpkgs.legacyPackages.${system};
      username = "meandres";
      hostname = "teto";
    in
    {
      nixosConfigurations = {
        teto = nixpkgs.lib.nixosSystem {
          specialArgs = { 
            inherit username; inherit hostname; inherit nixvim;
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
      homeConfigurations = {
        ilya = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            username = "ilya";
          };
          modules = [
            nixvim.homeModules.nixvim
            ./modules/standalone-home.nix
          ];
        };
      };
    };
}
