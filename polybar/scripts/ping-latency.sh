#!/bin/bash

# Ping Google DNS and get latency
latency=$(ping -c 1 -W 2 8.8.8.8 2>/dev/null | grep -oP 'time=\K[0-9.]+')

if [ -n "$latency" ]; then
    # Round to integer
    latency_int=${latency%.*}

    # Color based on latency
    if [ "$latency_int" -lt 50 ]; then
        echo "%{T4}󰛳%{T-} %{F#00FF41}${latency_int}ms%{F-}"
    elif [ "$latency_int" -lt 100 ]; then
        echo "%{T4}󰛳%{T-} %{F#FFD700}${latency_int}ms%{F-}"
    else
        echo "%{T4}󰛳%{T-} %{F#FF6347}${latency_int}ms%{F-}"
    fi
else
    echo "%{T4}󰛳%{T-} %{F#FF6347}---%{F-}"
fi
