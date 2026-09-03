# Waybar Configuration

This directory manages the top status bar.

## Files

- `config.jsonc`: The module layout, margins (`5px` standard gap), and click actions (e.g. launching the Orbit menu).
- `style-dark.css` & `style-light.css`: The CSS styling. The standard `12px` border-radius is applied uniformly to all modules for a cohesive look.

## Behavior

- **Orbit Integration**: Clicking the Wifi or Bluetooth modules triggers `orbit toggle`, launching the custom Rust-based overlay menu.
- **Volume & Networking**: Right-clicking volume or network icons opens `pavucontrol` and `nm-connection-editor` respectively.
