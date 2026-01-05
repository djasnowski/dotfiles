#!/bin/bash

# Get disk I/O stats for nvme0n1 (or first disk)
DISK="nvme0n1"
STAT_FILE="/tmp/.polybar_diskio"

# Read current stats
read_bytes=$(cat /sys/block/$DISK/stat 2>/dev/null | awk '{print $3}')
write_bytes=$(cat /sys/block/$DISK/stat 2>/dev/null | awk '{print $7}')

# Sectors are typically 512 bytes
read_bytes=$((read_bytes * 512))
write_bytes=$((write_bytes * 512))

# Read previous stats
if [ -f "$STAT_FILE" ]; then
    prev_read=$(cut -d' ' -f1 "$STAT_FILE")
    prev_write=$(cut -d' ' -f2 "$STAT_FILE")
else
    prev_read=$read_bytes
    prev_write=$write_bytes
fi

# Save current stats
echo "$read_bytes $write_bytes" > "$STAT_FILE"

# Calculate difference (per 3 seconds)
read_diff=$(( (read_bytes - prev_read) / 3 ))
write_diff=$(( (write_bytes - prev_write) / 3 ))

# Format speed
format_speed() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B/s"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))K/s"
    else
        echo "$((bytes / 1048576))M/s"
    fi
}

read_speed=$(format_speed $read_diff)
write_speed=$(format_speed $write_diff)

echo "%{T4}󰋊%{T-} ↓${read_speed} ↑${write_speed}"
