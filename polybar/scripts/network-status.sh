#!/bin/bash

# Function to calculate network speed
get_network_speed() {
    local interface=$1
    local old_rx="/tmp/.polybar_${interface}_rx"
    local old_tx="/tmp/.polybar_${interface}_tx"

    # Get current bytes
    local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)

    # Read old values
    local old_rx_bytes=$(cat $old_rx 2>/dev/null || echo $rx_bytes)
    local old_tx_bytes=$(cat $old_tx 2>/dev/null || echo $tx_bytes)

    # Calculate difference (bytes per interval)
    local rx_diff=$((rx_bytes - old_rx_bytes))
    local tx_diff=$((tx_bytes - old_tx_bytes))

    # Save current values for next run
    echo $rx_bytes > $old_rx
    echo $tx_bytes > $old_tx

    # Convert to human readable (KB/s or MB/s)
    format_speed() {
        local bytes=$1
        # Assuming 3 second interval, divide by 3 for per second rate
        local bytes_per_sec=$((bytes / 3))

        if [ $bytes_per_sec -lt 1024 ]; then
            echo "${bytes_per_sec}B/s"
        elif [ $bytes_per_sec -lt 1048576 ]; then
            echo "$((bytes_per_sec / 1024))KB/s"
        else
            echo "$((bytes_per_sec / 1048576))MB/s"
        fi
    }

    local down_speed=$(format_speed $rx_diff)
    local up_speed=$(format_speed $tx_diff)

    echo "↓$down_speed ↑$up_speed"
}

# Check if wired is connected
WIRED_STATE=$(ip link show enp8s0 2>/dev/null | grep -o "state [A-Z]*" | cut -d' ' -f2)

if [ "$WIRED_STATE" = "UP" ]; then
    # Wired is connected
    SPEED=$(get_network_speed enp8s0)
    echo " (Wired)  $SPEED"
else
    # Check WiFi
    WIFI_STATUS=$(nmcli -t -f active,ssid dev wifi | grep "^yes" | cut -d':' -f2)

    if [ -n "$WIFI_STATUS" ]; then
        # WiFi is connected
        SIGNAL=$(nmcli -t -f active,signal dev wifi | grep "^yes" | cut -d':' -f2)
        SPEED=$(get_network_speed wlp7s0)
        echo " $WIFI_STATUS  $SPEED"
    else
        echo " No Network"
    fi
fi
