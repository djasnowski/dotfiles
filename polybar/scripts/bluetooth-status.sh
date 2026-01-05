#!/bin/bash

# Check for connected bluetooth audio devices via pactl/pipewire
bt_sink=$(pactl list sinks | grep -A 3 "bluez_output" | grep "Description:" | cut -d':' -f2 | xargs)

if [ -n "$bt_sink" ]; then
    echo "%{T4}󰋋%{T-} $bt_sink"
else
    # Check if bluetooth is powered on
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        echo "%{T4}󰂯%{T-}"
    else
        echo "%{T4}󰂲%{T-}"
    fi
fi
