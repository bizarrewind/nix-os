{
  description = "VeXil Hyprland Config";

  inputs = {
    # The official NixOS package repository (using the unstable branch for latest apps)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
     
    # Fixed: Nested correctly inside the inputs attribute set
    claude-desktop.url = "github:Mowerick/claude-desktop-nix";

    # Home Manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
     
    # Stylix for global theming
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs:
    let
      userConfig = if builtins.pathExists ./user-config.nix
        then import ./user-config.nix
        else { username = "vexil"; };
      username = userConfig.username or "vexil";
      
      mkHomeConfig = user: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home.nix
          ./stylix.nix
          stylix.homeModules.stylix
        ];
      };
    in {
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

    homeConfigurations = {
      "vexil" = mkHomeConfig "vexil";
      "vexil@nixos" = mkHomeConfig "vexil";
    } // (if username != "vexil" then {
      "${username}" = mkHomeConfig username;
      "${username}@nixos" = mkHomeConfig username;
    } else {});
  };
}
