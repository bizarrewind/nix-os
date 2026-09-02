{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";

    # Generate palette dynamically from your custom wallpaper
    image = ./wallpapers/default.jpg;

    # Mostly Black OLED theme with accent colors dynamically drawn from the wallpaper
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

    # Preserve custom Catppuccin frosted glass style for Waybar
    # (Hyprlock is configured directly via ~/.config/hypr/hyprlock.conf)
    # targets.waybar is a home-manager stylix option, so we keep NixOS level targets clean
  };
}
