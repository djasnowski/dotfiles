#!/usr/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar -rq topright --config="$HOME/.config/polybar/config.ini" & polybar -rq main --config="$HOME/.config/polybar/config.ini" & polybar -rq bottom --config="$HOME/.config/polybar/config.ini" &

echo "Polybar launched..."
