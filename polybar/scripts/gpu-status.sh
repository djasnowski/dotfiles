#!/bin/bash

# Get NVIDIA GPU stats
gpu_info=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)

if [ -n "$gpu_info" ]; then
    gpu_util=$(echo "$gpu_info" | cut -d',' -f1 | xargs)
    gpu_temp=$(echo "$gpu_info" | cut -d',' -f2 | xargs)
    mem_used=$(echo "$gpu_info" | cut -d',' -f3 | xargs)
    mem_total=$(echo "$gpu_info" | cut -d',' -f4 | xargs)

    # Calculate memory percentage
    mem_pct=$((mem_used * 100 / mem_total))

    echo "%{T4}󰍹%{T-} ${gpu_util}% ${gpu_temp}°C ${mem_pct}%"
else
    echo "%{T4}󰍹%{T-} N/A"
fi
