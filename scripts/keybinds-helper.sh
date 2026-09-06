#!/usr/bin/env bash
# =============================================================================
# Crystal UI — Interactive Keybinds Cheatsheet
# =============================================================================

BINDS="
🚀 Win + Return          Open Terminal (Kitty)
🌐 Win + B               Open Web Browser (Firefox)
📁 Win + E               Open File Manager (Dolphin)
🔍 Win + Space           Application Launcher (Rofi)
🔁 Alt + Tab             Switch Open Windows (Rofi)
📋 Win + C               Clipboard History Manager (Rofi)
🔔 Win + N               Toggle Notification Drawer (SwayNC)
🚪 Win + Escape          Power & Session Menu (wlogout)
🔒 Win + Delete          Lock Screen (hyprlock)
🪟 Win + V               Toggle Window Float
⛶  Win + M               Maximize Window (Retaining Bar)
🖥️ Win + F               True Fullscreen Toggle
📸 Win + Shift + S       Region Screenshot (Hyprshot)
🔀 Win + H / J / K / L   Vim Focus (Left / Down / Up / Right)
🔄 Win + Shift + H/J/K/L Move Window Position
↔️  Win + R               Interactive Window Resize Mode
🔢 Win + 1..9            Switch Workspace
📌 Win + P               Special Scratchpad Workspace
❌ Win + Q               Close Focused Window
"

echo "$BINDS" | sed '/^[[:space:]]*$/d' | rofi -dmenu -i -p "⌨ Shortcuts" \
    -theme-str 'window { width: 680px; }' \
    -theme-str 'listview { lines: 12; }' \
    -theme-str 'element-icon { enabled: false; }'
