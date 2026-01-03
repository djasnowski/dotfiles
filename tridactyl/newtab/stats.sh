#!/bin/bash
# Writes system stats to stats.json for newtab page

STATS_FILE="$HOME/.config/tridactyl/newtab/stats.json"
NET_IFACE=$(ip route | awk '/default/ {print $5; exit}')

# Store previous network bytes for speed calculation
PREV_RX=0
PREV_TX=0

while true; do
  CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)
  MEM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
  MEM_USED=$(free -g | awk '/Mem:/ {print $3}')GB
  MEM_TOTAL=$(free -g | awk '/Mem:/ {print $2}')GB
  DISK=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
  DISK_USED=$(df -h / | awk 'NR==2 {print $3}' | sed 's/G$/GB/')
  DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}' | sed 's/G$/GB/')
  UPTIME=$(uptime -p | sed 's/up //; s/ hours\?/h /g; s/ minutes\?/m/g; s/ days\?/d /g; s/, //g')

  # GPU stats (NVIDIA)
  GPU_DATA=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)
  GPU_UTIL=$(echo "$GPU_DATA" | awk -F', ' '{print $1}')
  GPU_TEMP=$(echo "$GPU_DATA" | awk -F', ' '{print $2}')
  GPU_MEM_USED=$(echo "$GPU_DATA" | awk -F', ' '{printf "%.1f", $3/1024}')
  GPU_MEM_TOTAL=$(echo "$GPU_DATA" | awk -F', ' '{printf "%.0f", $4/1024}')

  # Network speed (bytes per 5 sec interval)
  CURR_RX=$(cat /sys/class/net/$NET_IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
  CURR_TX=$(cat /sys/class/net/$NET_IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
  if [ $PREV_RX -gt 0 ]; then
    RX_SPEED=$(( (CURR_RX - PREV_RX) / 5 ))
    TX_SPEED=$(( (CURR_TX - PREV_TX) / 5 ))
    # Convert to human readable
    if [ $RX_SPEED -gt 1048576 ]; then
      RX_FMT="$(echo "scale=1; $RX_SPEED/1048576" | bc)MB"
    elif [ $RX_SPEED -gt 1024 ]; then
      RX_FMT="$(echo "scale=0; $RX_SPEED/1024" | bc)KB"
    else
      RX_FMT="${RX_SPEED}B"
    fi
    if [ $TX_SPEED -gt 1048576 ]; then
      TX_FMT="$(echo "scale=1; $TX_SPEED/1048576" | bc)MB"
    elif [ $TX_SPEED -gt 1024 ]; then
      TX_FMT="$(echo "scale=0; $TX_SPEED/1024" | bc)KB"
    else
      TX_FMT="${TX_SPEED}B"
    fi
  else
    RX_FMT="--"
    TX_FMT="--"
  fi
  PREV_RX=$CURR_RX
  PREV_TX=$CURR_TX

  # Top process by CPU
  TOP_PROC=$(ps -eo comm --sort=-%cpu | head -2 | tail -1)

  # System info (static, but included for completeness)
  HOSTNAME=$(hostname)
  KERNEL=$(uname -r | cut -d'-' -f1)
  DISTRO=$(cat /etc/os-release | grep "^PRETTY_NAME" | cut -d'"' -f2)

  # Quick stats
  LOAD_AVG=$(cat /proc/loadavg | awk '{print $1}')
  PROC_COUNT=$(ps -e --no-headers | wc -l)

  # Sensor temps
  CPU_TEMP=$(sensors k10temp-pci-00c3 2>/dev/null | awk '/Tctl:/ {gsub(/[+°C]/,"",$2); print $2}')
  PCH_TEMP=$(sensors gigabyte_wmi-virtual-0 2>/dev/null | awk '/temp3:/ {gsub(/[+°C]/,"",$2); print $2}')
  VRM_TEMP=$(sensors gigabyte_wmi-virtual-0 2>/dev/null | awk '/temp5:/ {gsub(/[+°C]/,"",$2); print $2}')
  VRM2_TEMP=$(sensors gigabyte_wmi-virtual-0 2>/dev/null | awk '/temp6:/ {gsub(/[+°C]/,"",$2); print $2}')
  NVME_TEMP=$(sensors nvme-pci-1000 2>/dev/null | awk '/Composite:/ {gsub(/[+°C]/,"",$2); print $2}')

  cat > "$STATS_FILE" << EOF
{
  "cpu": $CPU,
  "mem": $MEM,
  "memUsed": "$MEM_USED",
  "memTotal": "$MEM_TOTAL",
  "disk": $DISK,
  "diskUsed": "$DISK_USED",
  "diskTotal": "$DISK_TOTAL",
  "uptime": "$UPTIME",
  "gpuUtil": ${GPU_UTIL:-0},
  "gpuTemp": ${GPU_TEMP:-0},
  "gpuMemUsed": "${GPU_MEM_USED:-0}GB",
  "gpuMemTotal": "${GPU_MEM_TOTAL:-0}GB",
  "netDown": "$RX_FMT",
  "netUp": "$TX_FMT",
  "topProc": "$TOP_PROC",
  "cpuTemp": "${CPU_TEMP:-0}",
  "pchTemp": "${PCH_TEMP:-0}",
  "vrmTemp": "${VRM_TEMP:-0}",
  "nvmeTemp": "${NVME_TEMP:-0}",
  "hostname": "$HOSTNAME",
  "kernel": "$KERNEL",
  "distro": "$DISTRO",
  "loadAvg": "$LOAD_AVG",
  "procCount": "$PROC_COUNT"
}
EOF

  sleep 5
done
