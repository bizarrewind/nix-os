#!/usr/bin/env bash
# =============================================================================
# Smart Battery Monitor Daemon
# Provides multi-stage low battery warnings and safe suspend on critical level
# =============================================================================

# Find battery device in sysfs
BAT_DIR=$(find /sys/class/power_supply -name "BAT*" | head -n 1)

if [ -z "$BAT_DIR" ] || [ ! -d "$BAT_DIR" ]; then
    # No battery found (e.g. desktop PC)
    exit 0
fi

# Track state to avoid spamming notifications
WARNED_LOW=false
WARNED_CRITICAL=false
WARNED_EMERGENCY=false

while true; do
    if [ -f "$BAT_DIR/capacity" ] && [ -f "$BAT_DIR/status" ]; then
        CAPACITY=$(cat "$BAT_DIR/capacity" 2>/dev/null || echo 100)
        STATUS=$(cat "$BAT_DIR/status" 2>/dev/null || echo "Unknown")

        if [ "$STATUS" = "Discharging" ]; then
            # 1. Emergency stage (<= 4%): Immediate warning & safe suspend
            if [ "$CAPACITY" -le 4 ]; then
                if [ "$WARNED_EMERGENCY" = false ]; then
                    WARNED_EMERGENCY=true
                    notify-send -u critical -a "Power Manager" \
                        -i battery-caution \
                        "🚨 Battery Depleted (${CAPACITY}%)" \
                        "System is putting itself to sleep now to save your work. Plug in your charger!"
                    
                    # Beep alert sound
                    pw-play /run/current-system/sw/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
                    
                    sleep 3
                    systemctl suspend
                fi

            # 2. Critical stage (<= 10%): Critical alert
            elif [ "$CAPACITY" -le 10 ]; then
                if [ "$WARNED_CRITICAL" = false ]; then
                    WARNED_CRITICAL=true
                    notify-send -u critical -a "Power Manager" \
                        -i battery-low \
                        "⚠️ Battery Critically Low (${CAPACITY}%)" \
                        "Please plug in your AC charger immediately! System will sleep soon."
                fi

            # 3. Low stage (<= 20%): Standard alert
            elif [ "$CAPACITY" -le 20 ]; then
                if [ "$WARNED_LOW" = false ]; then
                    WARNED_LOW=true
                    notify-send -u normal -a "Power Manager" \
                        -i battery-low \
                        "Low Battery (${CAPACITY}%)" \
                        "Battery level is dropping. Consider connecting a power source."
                fi
            else
                # Reset warnings if capacity is above 20%
                WARNED_LOW=false
                WARNED_CRITICAL=false
                WARNED_EMERGENCY=false
            fi
        else
            # Battery is Charging, Full, or on AC power -> reset notification flags
            if [ "$WARNED_LOW" = true ] || [ "$WARNED_CRITICAL" = true ] || [ "$WARNED_EMERGENCY" = true ]; then
                notify-send -u low -a "Power Manager" \
                    -i battery-charging \
                    "Charger Connected" \
                    "Battery is now ${STATUS,,} (${CAPACITY}%)."
            fi
            WARNED_LOW=false
            WARNED_CRITICAL=false
            WARNED_EMERGENCY=false
        fi
    fi

    # Check every 30 seconds
    sleep 30
done
