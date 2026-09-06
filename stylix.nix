{ pkgs, lib, ... }:

let
  # Preset options: Set to null to auto-generate colors from the wallpaper!
  # Or uncomment any preset group to switch the whole desktop color mood instantly:
  # Examples from base16-schemes: "catppuccin-mocha", "tokyo-night-dark", "gruvbox-dark-medium", "nord", "dracula", "rose-pine", "kanagawa"
  colorPreset = null;
in
{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";

    # Generate palette dynamically from your wallpaper
    image = ./wallpapers/default.jpg;

    # If colorPreset is set, use that Base16 scheme; otherwise Stylix auto-extracts from the wallpaper!
    base16Scheme = lib.mkIf (colorPreset != null) "${pkgs.base16-schemes}/share/themes/${colorPreset}.yaml";

    # Deep OLED Black background with accent colors dynamically drawn from the wallpaper
    override = {
      base00 = "000000"; # Pure OLED Black background
      base01 = "0a0a0f"; # Deep black card/surface
      base02 = "14141d"; # Elevated container
      base03 = "282835"; # Subtle borders / outlines
    };

    # Typography configured across all desktop and terminal applications
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        terminal = 12;
        desktop = 10;
        popups = 11;
      };
    };

    # System-wide cursor theme
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # System-wide icon theme
    icons = {
      enable = true;
      package = pkgs.kdePackages.breeze-icons;
      dark = "breeze-dark";
      light = "breeze";
    };

    opacity = {
      terminal = 0.80;
    };
  };
}
