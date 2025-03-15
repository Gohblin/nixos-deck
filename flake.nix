{
  description = "NixOS configuration for Steam Deck with Jovian";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, jovian, home-manager, plasma-manager, ... }@inputs: {
    nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./nixos/modules
        jovian.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.deck = { ... }: {
            imports = [ 
              ./home-manager/modules
              plasma-manager.homeManagerModules.plasma-manager
            ];
            # Basic home-manager configuration
            home.username = "deck";
            home.homeDirectory = "/home/deck";
            home.stateVersion = "24.05";
            programs.home-manager.enable = true;
          };
        }
      ];
    };
  };
}
