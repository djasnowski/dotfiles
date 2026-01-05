#!/bin/bash

# Get load averages
load=$(cat /proc/loadavg | cut -d' ' -f1-3)
load1=$(echo "$load" | cut -d' ' -f1)

echo "%{T4}󰊚%{T-} $load1"
