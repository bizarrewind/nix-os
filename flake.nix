{
  description = "VeXil Hyprland Config";

  inputs = {
    # The official NixOS package repository (using the unstable branch for latest apps)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
     
    # Stylix for global theming
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          stylix.nixosModules.stylix
        ];
      };
    };

    homeConfigurations."vexil@nixos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ./home.nix
      ];
    };
  };
}
