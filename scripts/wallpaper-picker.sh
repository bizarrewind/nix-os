#!/usr/bin/env bash
# =============================================================================
# Crystal UI — Interactive Rofi Wallpaper Selector & Switcher
# =============================================================================

set -euo pipefail

# Wallpaper directories to search
WALLPAPER_DIRS=(
    "$HOME/.dotfiles/nixos/wallpapers"
    "$HOME/Pictures/wallpapers"
    "$HOME/Pictures"
)

# Collect all image files (.jpg, .jpeg, .png, .webp)
declare -A WALLPAPERS
ENTRIES=""

for dir in "${WALLPAPER_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        while IFS= read -r -d '' file; do
            filename=$(basename "$file")
            # Ignore screenshots
            if [[ "${filename,,}" =~ (screenshot|hyprshot) ]]; then
                continue
            fi
            clean_name="${filename%.*}"
            # Format clean name: replace underscores/dashes with spaces and capitalize
            clean_name=$(echo "$clean_name" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
            
            # Prevent duplicate names
            if [ -z "${WALLPAPERS[$clean_name]:-}" ]; then
                WALLPAPERS["$clean_name"]="$file"
                ENTRIES="${ENTRIES}${clean_name}\0icon\x1f${file}\n"
            fi
        done < <(find "$dir" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -print0 2>/dev/null)
    fi
done

if [ -z "$ENTRIES" ]; then
    notify-send -a "Wallpaper" -i dialog-warning "Wallpaper Picker" "No wallpapers found in ~/Pictures or ~/.dotfiles/nixos/wallpapers"
    exit 0
fi

# Show interactive Rofi selector
SELECTED=$(printf "%b" "$ENTRIES" | rofi -dmenu -i -p "󰸉 Wallpaper" -mesg "Choose wallpaper to apply live animated transition" || true)

if [ -n "$SELECTED" ] && [ -n "${WALLPAPERS[$SELECTED]:-}" ]; then
    IMG_PATH="${WALLPAPERS[$SELECTED]}"
    
    # Apply wallpaper smoothly using awww
    if command -v awww >/dev/null 2>&1; then
        awww img "$IMG_PATH" \
            --transition-type wipe \
            --transition-angle 30 \
            --transition-step 90 \
            --transition-fps 60
    fi
    
    # Persist active wallpaper choice
    mkdir -p "$HOME/.config"
    echo "$IMG_PATH" > "$HOME/.config/current_wallpaper"
    
    # Notify user with clean vector icon
    notify-send -a "Wallpaper" -i image-x-generic "Wallpaper Applied" "$SELECTED" -t 2000
fi
