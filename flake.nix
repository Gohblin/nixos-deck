{
  description = "Joshua's NixOS Steamdeck Configuration";

  inputs = {
    # Core inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Zen browser flake
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:kaylorben/nixcord";

    nix-snapd.url = "github:nix-community/nix-snapd";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";

    # Add Jovian-NixOS as an input
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS/development";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    zen-browser,
    nixcord,
    nix-snapd,
    jovian,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/default.nix
          #./steamdeck.nix
          nix-snapd.nixosModules.default

          # Import Jovian modules
          jovian.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.deck = import ./home-manager/default.nix;

            home-manager.sharedModules = [
              inputs.nixcord.homeManagerModules.nixcord
            ];

            # Pass flake inputs to home-manager configuration
            home-manager.extraSpecialArgs = {
              inherit inputs zen-browser;
            };
          }
        ];

        # Pass flake inputs to NixOS configuration
        specialArgs = {inherit inputs;};
      };
    };

    homeConfigurations = {
      "deck@nixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/default.nix
          {
            # Zen-browser configuration
            home.packages = [zen-browser.packages.${system}.default];
          }
        ];
        extraSpecialArgs = {inherit inputs;};
      };
    };

    nixosModules = import ./nixos/modules;
    homeManagerModules = import ./home-manager/modules;

  };
}
