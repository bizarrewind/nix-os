#!/usr/bin/env bash
# Toggle between Dark Glass and Clear White Glass theme modes

NIXOS_DIR="$HOME/.dotfiles/nixos"
STATE_FILE="$HOME/.cache/glass-theme-state"

# Determine current state (default to dark if not set)
if [ ! -f "$STATE_FILE" ]; then
    echo "dark" > "$STATE_FILE"
fi
CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" = "dark" ]; then
    NEW_STATE="light"
else
    NEW_STATE="dark"
fi

echo "Switching to $NEW_STATE glass mode..."

# 1. Update Symlinks (relative targets for portability across machines)
ln -sf "style-${NEW_STATE}.css" "$NIXOS_DIR/waybar/style.css"
ln -sf "style-${NEW_STATE}.css" "$NIXOS_DIR/wlogout/style.css"
ln -sf "crystal-ui-${NEW_STATE}.rasi" "$NIXOS_DIR/rofi/themes/crystal-ui.rasi"

# 2. Update Hyprland Blur Settings dynamically
if [ "$NEW_STATE" = "light" ]; then
    # Clear Lens Refraction (No fog, no noise)
    hyprctl eval 'hl.config({ decoration = { blur = { noise = 0.0, contrast = 1.0, vibrancy = 0.0 } } })'
else
    # Dark Frosted Glass (Textured, higher vibrancy)
    hyprctl eval 'hl.config({ decoration = { blur = { noise = 0.02, contrast = 0.95, vibrancy = 0.25 } } })'
fi

# 3. Reload UI Components
pkill -x waybar || true
sleep 0.2
waybar & disown

# Save state
echo "$NEW_STATE" > "$STATE_FILE"

# Notify user (if notify-send is available)
if command -v notify-send >/dev/null; then
    notify-send "Glass Theme" "Switched to $NEW_STATE mode"
fi
