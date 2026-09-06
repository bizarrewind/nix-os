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

notify-send -a "Brightness" -h string:x-canonical-private-synchronous:osd-bright -h int:value:"$BRIGHT" -i display-brightness "Brightness" "${BRIGHT}%" -t 1200
