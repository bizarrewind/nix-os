#!/usr/bin/env bash
# =============================================================================
# Crystal UI — Volume Controller with Visual On-Screen Display (OSD)
# =============================================================================

ACTION="$1"

case "$ACTION" in
    up)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac

# Read current volume and state
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED" || true)
VOL_FLOAT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
VOL=$(python3 -c "print(int(float('${VOL_FLOAT:-0}') * 100))" 2>/dev/null || echo "50")

# Determine icon (prefer dedicated high-res SVGs)
ICON_DIR="$HOME/.config/swaync/icons"

if [ -n "$MUTED" ] || [ "$VOL" -eq 0 ]; then
    ICON="$ICON_DIR/volume-muted.svg"
    [ ! -f "$ICON" ] && ICON="notification-audio-volume-muted"
    notify-send -a "Volume" -h string:x-canonical-private-synchronous:osd-volume -h int:value:0 -i "$ICON" "Volume" "Muted" -t 1200
elif [ "$VOL" -lt 35 ]; then
    ICON="$ICON_DIR/volume-low.svg"
    [ ! -f "$ICON" ] && ICON="notification-audio-volume-low"
    notify-send -a "Volume" -h string:x-canonical-private-synchronous:osd-volume -h int:value:"$VOL" -i "$ICON" "Volume" "${VOL}%" -t 1200
elif [ "$VOL" -lt 70 ]; then
    ICON="$ICON_DIR/volume-medium.svg"
    [ ! -f "$ICON" ] && ICON="notification-audio-volume-medium"
    notify-send -a "Volume" -h string:x-canonical-private-synchronous:osd-volume -h int:value:"$VOL" -i "$ICON" "Volume" "${VOL}%" -t 1200
else
    ICON="$ICON_DIR/volume-high.svg"
    [ ! -f "$ICON" ] && ICON="notification-audio-volume-high"
    notify-send -a "Volume" -h string:x-canonical-private-synchronous:osd-volume -h int:value:"$VOL" -i "$ICON" "Volume" "${VOL}%" -t 1200
fi
