#!/usr/bin/env bash
# =============================================================================
# Crystal UI — Clipboard Manager (Rofi + Cliphist)
# =============================================================================

# Show clipboard history in a clean centered Rofi window
SELECTION=$(cliphist list | rofi -dmenu -p "󰅌 Clipboard" \
    -theme-str 'window { width: 620px; }' \
    -theme-str 'listview { lines: 9; }' \
    -theme-str 'element-icon { enabled: false; }')

if [ -n "$SELECTION" ]; then
    echo "$SELECTION" | cliphist decode | wl-copy
fi
