#!/bin/bash

# Auto-detect connected monitors
CONNECTED_MONITORS=($(xrandr | grep " connected" | awk '{print $1}'))
LAPTOP_SCREEN=$(xrandr | grep "^eDP" | grep " connected" | awk '{print $1}')
EXTERNAL_MONITORS=($(xrandr | grep -E "^(DP-|HDMI-|DVI-)" | grep " connected" | awk '{print $1}'))

echo "Detected monitors: ${CONNECTED_MONITORS[*]}"
echo "Laptop screen: ${LAPTOP_SCREEN:-none}"
echo "External monitors: ${EXTERNAL_MONITORS[*]:-none}"

# Determine which monitors to use
if [ ${#EXTERNAL_MONITORS[@]} -gt 0 ] && [ -n "$LAPTOP_SCREEN" ]; then
    # Laptop with external monitors - disable laptop screen
    echo "Laptop with external monitors detected, disabling laptop screen..."
    xrandr --output "$LAPTOP_SCREEN" --off
    MONITORS=("${EXTERNAL_MONITORS[@]}")
elif [ ${#EXTERNAL_MONITORS[@]} -gt 0 ]; then
    # Desktop with external monitors
    echo "Desktop monitors detected..."
    MONITORS=("${EXTERNAL_MONITORS[@]}")
elif [ -n "$LAPTOP_SCREEN" ]; then
    # Laptop screen only - use 200% scaling for HiDPI
    echo "Laptop screen only, using HiDPI scaling..."
    xrandr --output "$LAPTOP_SCREEN" --auto --scale 0.5x0.5 --primary
    MONITORS=("$LAPTOP_SCREEN")
else
    echo "No monitors detected!"
    exit 1
fi

# Configure monitors: first is primary, others arranged to the right
PRIMARY="${MONITORS[0]}"
xrandr --output "$PRIMARY" --auto --primary
echo "Primary monitor: $PRIMARY"

PREV="$PRIMARY"
for ((i=1; i<${#MONITORS[@]}; i++)); do
    MON="${MONITORS[$i]}"
    xrandr --output "$MON" --auto --right-of "$PREV"
    echo "Secondary monitor: $MON (right of $PREV)"
    PREV="$MON"
done

# Restart Polybar
echo "Restarting Polybar..."
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar on each monitor
POLYBAR_CONFIG="$HOME/.config/polybar/config.ini"
for ((i=0; i<${#MONITORS[@]}; i++)); do
    MON="${MONITORS[$i]}"
    if [ $i -eq 0 ]; then
        # Primary monitor gets main and bottom bars
        MONITOR=$MON polybar -rq main --config="$POLYBAR_CONFIG" 2>&1 | tee -a /tmp/polybar-main.log & disown
        MONITOR=$MON polybar -rq bottom --config="$POLYBAR_CONFIG" 2>&1 | tee -a /tmp/polybar-bottom.log & disown
        echo "Launched polybar main+bottom on $MON"
    else
        # Secondary monitors get topright bar
        MONITOR=$MON polybar -rq topright --config="$POLYBAR_CONFIG" 2>&1 | tee -a /tmp/polybar-topright.log & disown
        echo "Launched polybar topright on $MON"
    fi
done

echo "Display configuration complete!"