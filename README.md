# Crystal UI Dotfiles

A premium, highly-customized NixOS dotfiles repository built with Hyprland, Waybar, and a unified glassmorphic aesthetic ("Crystal UI"). 

## Features

- **Hyprland**: Smooth animations, custom window rules (like floating Picture-in-Picture), and a finely-tuned master layout.
- **Waybar**: A highly responsive, modular top-bar styled with translucent effects.
- **Global Stylix Integration**: Dynamic wallpaper-based theming automatically applied to Neovim (via base16), Firefox (via userChrome), VS Code, Rofi, and SwayNC.
- **Neovim**: Lazy.nvim configured with Telescope, Treesitter, and dynamic Stylix palette support.
- **Unified Geometry**: A synchronized `12px` border-radius applied across every single UI component for a perfectly consistent, premium feel.
- **Custom Orbit Menu**: A custom-built rust/GTK based overlay menu for bluetooth and wifi.

## Gallery

*(Insert screenshots here!)*

| Desktop | Applications |
|---------|--------------|
| ![Desktop Placeholder]() | ![Apps Placeholder]() |

## Directory Structure

- `/hypr` - Hyprland window manager configurations, layer rules, and animations. [Read more](./hypr/README.md)
- `/waybar` - Waybar modules and CSS styling. [Read more](./waybar/README.md)
- `/nvim` - Neovim lua configuration using lazy.nvim. [Read more](./nvim/README.md)
- `/eww` - Eww widgets (e.g. Volume Control).
- `/rofi` - Application launcher themes.
- `/swaync` - Notification center styling.
- `home.nix` & `configuration.nix` - The core NixOS system declarations.

## Installation

```bash
# Clone the repository
git clone <your-repo-url> ~/.dotfiles/nixos

# Apply system changes
sudo nixos-rebuild switch --flake ~/.dotfiles/nixos#nixos

# Apply user environment (Home Manager)
home-manager switch --flake ~/.dotfiles/nixos#$USER
```

## Maintenance

This repository utilizes Home Manager and Flakes to manage the state. If you edit anything outside of `/home/$USER/.dotfiles/nixos/`, the changes will be overwritten on the next rebuild. 

When adding new packages, add them to `home.nix` (for user-specific tools) or `pkgs.nix` (for system-wide utilities).
