#!/bin/bash

# Count running docker containers
count=$(docker ps -q 2>/dev/null | wc -l)

if [ "$count" -gt 0 ]; then
    echo "%{T4}󰡨%{T-} $count"
else
    echo "%{T4}󰡨%{T-} %{F#666666}0%{F-}"
fi
