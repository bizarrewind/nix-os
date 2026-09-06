#!/usr/bin/env bash
# =============================================================================
# Crystal UI — Modern Screenshot Utility with Live Preview & Actions
# =============================================================================

set -euo pipefail

MODE="${1:-region}"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="Screenshot_${TIMESTAMP}.png"
FILEPATH="${SCREENSHOT_DIR}/${FILENAME}"

GEOMETRY=""

case "$MODE" in
    region|area)
        # Select region with slurp; exit quietly if cancelled (e.g. Escape)
        GEOMETRY=$(slurp -b "#00000088" -c "#e8a83a" -s "#ffffff15" -w 2 2>/dev/null || true)
        [ -z "$GEOMETRY" ] && exit 0
        grim -g "$GEOMETRY" "$FILEPATH"
        ;;
    window)
        # Grab active window geometry using hyprctl
        GEOMETRY=$(python3 -c "
import json, subprocess
try:
    win = json.loads(subprocess.check_output(['hyprctl', 'activewindow', '-j']))
    x, y = win['at']
    w, h = win['size']
    if w > 0 and h > 0:
        print(f'{x},{y} {w}x{h}')
except Exception:
    pass
" 2>/dev/null || true)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILEPATH"
        else
            # Fallback to slurp window selection
            GEOMETRY=$(slurp 2>/dev/null || true)
            [ -z "$GEOMETRY" ] && exit 0
            grim -g "$GEOMETRY" "$FILEPATH"
        fi
        ;;
    fullscreen|output|screen)
        grim "$FILEPATH"
        ;;
    *)
        echo "Usage: $0 [region|window|fullscreen]"
        exit 1
        ;;
esac

if [ ! -f "$FILEPATH" ]; then
    exit 0
fi

# Copy image directly to system clipboard
wl-copy --type image/png < "$FILEPATH"

# Send rich notification with thumbnail preview and action buttons asynchronously
(
    ACTION=$(notify-send -a "Screenshot" \
        -i "$FILEPATH" \
        "Screenshot Captured" \
        "Saved to ~/Pictures/Screenshots & clipboard" \
        -t 4000 \
        --action="open=Open" \
        --action="folder=Show in Folder" 2>/dev/null || true)

    case "$ACTION" in
        open)
            xdg-open "$FILEPATH" &>/dev/null &
            ;;
        folder)
            xdg-open "$SCREENSHOT_DIR" &>/dev/null &
            ;;
    esac
) &>/dev/null &
exit 0
