#!/usr/bin/env bash
# =============================================================================
# Crystal UI — Display Backlight Controller with Visual OSD
# =============================================================================

ACTION="$1"

case "$ACTION" in
    up)
        brightnessctl -e4 -n2 set 5%+
        ;;
    down)
        brightnessctl -e4 -n2 set 5%-
        ;;
esac

BRIGHT=$(brightnessctl -m | awk -F, '{print substr($4, 1, length($4)-1)}')
[ -z "$BRIGHT" ] && BRIGHT=50

ICON_DIR="$HOME/.config/swaync/icons"
if [ "$BRIGHT" -lt 35 ]; then
    ICON="$ICON_DIR/brightness-low.svg"
    [ ! -f "$ICON" ] && ICON="notification-display-brightness-low"
elif [ "$BRIGHT" -lt 70 ]; then
    ICON="$ICON_DIR/brightness-medium.svg"
    [ ! -f "$ICON" ] && ICON="notification-display-brightness-medium"
else
    ICON="$ICON_DIR/brightness-high.svg"
    [ ! -f "$ICON" ] && ICON="notification-display-brightness-high"
fi

notify-send -a "Brightness" -h string:x-canonical-private-synchronous:osd-bright -h int:value:"$BRIGHT" -i "$ICON" "Brightness" "${BRIGHT}%" -t 1200
