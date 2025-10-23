#!/bin/bash

# Check if external monitors are connected
EXTERNAL_CONNECTED=$(xrandr | grep -E "^(DP-|HDMI-|DVI-)" | grep " connected" | wc -l)

if [ "$EXTERNAL_CONNECTED" -gt 0 ]; then
    # External monitors connected - use them, disable laptop screen
    echo "External monitors detected, configuring..."
    xrandr --output eDP-1 --off \
           --output DVI-I-1-1 --auto --primary \
           --output DP-2 --auto --right-of DVI-I-1-1

    # Set monitors for Polybar
    export MONITOR_MAIN=DVI-I-1-1
    export MONITOR_RIGHT=DP-2
else
    # Only laptop screen - use 200% scaling
    echo "No external monitors, using laptop screen with 200% scaling..."

    # First, move all workspaces to eDP-1
    echo "Moving all workspaces to laptop screen..."
    for ws in $(i3-msg -t get_workspaces | jq -r '.[].name'); do
        i3-msg "[workspace=\"$ws\"]" move workspace to output eDP-1
    done

    # Configure display
    xrandr --output eDP-1 --mode 3840x2400 --scale 0.5x0.5 --primary \
           --output DVI-I-1-1 --off \
           --output DP-2 --off \
           --output DP-1 --off \
           --output DP-3 --off \
           --output DP-4 --off \
           --output DP-5 --off \
           --output DVI-I-2-2 --off \
           --output DVI-I-3-3 --off \
           --output DVI-I-4-4 --off \
           --output HDMI-1 --off

    # Set primary monitor for Polybar
    export MONITOR=eDP-1
fi

# Restart Polybar with correct monitor
echo "Restarting Polybar..."
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar based on monitor setup
if [ "$EXTERNAL_CONNECTED" -gt 0 ]; then
    # Launch bars for external monitors
    MONITOR=$MONITOR_MAIN polybar main 2>&1 | tee -a /tmp/polybar-main.log & disown
    MONITOR=$MONITOR_MAIN polybar bottom 2>&1 | tee -a /tmp/polybar-bottom.log & disown
    MONITOR=$MONITOR_RIGHT polybar topright 2>&1 | tee -a /tmp/polybar-topright.log & disown
else
    # Launch bars for laptop screen
    MONITOR=$MONITOR polybar main 2>&1 | tee -a /tmp/polybar-main.log & disown
    MONITOR=$MONITOR polybar bottom 2>&1 | tee -a /tmp/polybar-bottom.log & disown
fi

echo "Display configuration complete!"