# Hyprland Configuration

This directory houses the window manager configuration for Hyprland.

## Files

- `hyprland.lua`: The main configuration file handling monitor setup, general variables (like the standard `12px` rounding), animations, window rules, and layer rules.
- `keybinds.lua`: Defines all keyboard shortcuts for managing windows and launching applications.
- `hyprlock.conf`: The lock screen configuration. Note that its colors are dynamically injected by Stylix via Home Manager.

## Features

- **Picture-in-Picture Support**: YouTube PiP windows (Firefox) are automatically floated and pinned across all workspaces.
- **Translucent Layers**: Popups and notification windows (`swaync-notification-window`, `swaync-control-center`) have blur explicitly enabled for a glassy effect.
- **Fade Animations**: The Orbit overlay menu utilizes a `fade` animation instead of slide, to fix flickering when toggled.
