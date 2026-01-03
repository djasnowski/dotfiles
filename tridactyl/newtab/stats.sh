#!/bin/bash
# Writes system stats to stats.json for newtab page

STATS_FILE="$HOME/.config/tridactyl/newtab/stats.json"
HISTORY_FILE="$HOME/.config/tridactyl/newtab/stats_history.json"
HISTORY_SIZE=360  # 30 minutes at 5s intervals
NET_IFACE=$(ip route | awk '/default/ {print $5; exit}')
NUM_CORES=$(nproc)

# Initialize history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
  echo '{"cpu":[],"mem":[],"netDown":[],"netUp":[],"cpuTemp":[],"gpuTemp":[]}' > "$HISTORY_FILE"
fi

# Store previous values for delta calculations
PREV_RX=0
PREV_TX=0
PREV_DISK_READ=0
PREV_DISK_WRITE=0
declare -a PREV_CPU_TOTAL PREV_CPU_IDLE

# Package updates (cached, updated every 10 minutes)
PKG_UPDATES=0
PKG_UPDATE_COUNT=0

# Initialize previous CPU arrays
for ((i=0; i<NUM_CORES; i++)); do
  PREV_CPU_TOTAL[$i]=0
  PREV_CPU_IDLE[$i]=0
done

while true; do
  # Per-core CPU usage
  CORE_USAGE=""
  for ((i=0; i<NUM_CORES; i++)); do
    read -r _ user nice system idle iowait irq softirq steal _ _ < <(grep "^cpu$i " /proc/stat)
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_time=$idle

    if [ ${PREV_CPU_TOTAL[$i]} -gt 0 ]; then
      diff_total=$((total - PREV_CPU_TOTAL[$i]))
      diff_idle=$((idle_time - PREV_CPU_IDLE[$i]))
      if [ $diff_total -gt 0 ]; then
        usage=$(( (diff_total - diff_idle) * 100 / diff_total ))
      else
        usage=0
      fi
    else
      usage=0
    fi

    PREV_CPU_TOTAL[$i]=$total
    PREV_CPU_IDLE[$i]=$idle_time

    if [ -n "$CORE_USAGE" ]; then
      CORE_USAGE="$CORE_USAGE,$usage"
    else
      CORE_USAGE="$usage"
    fi
  done

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

  # Swap usage
  SWAP_DATA=$(free | awk '/Swap:/ {if ($2 > 0) printf "%.0f %d %d", $3/$2*100, $3/1024/1024, $2/1024/1024; else print "0 0 0"}')
  SWAP_PCT=$(echo "$SWAP_DATA" | awk '{print $1}')
  SWAP_USED=$(echo "$SWAP_DATA" | awk '{print $2}')GB
  SWAP_TOTAL=$(echo "$SWAP_DATA" | awk '{print $3}')GB

  # CPU frequency (average across cores, in GHz)
  CPU_FREQ=$(awk '/cpu MHz/ {sum+=$4; count++} END {if(count>0) printf "%.2f", sum/count/1000}' /proc/cpuinfo)

  # Disk I/O (bytes per 5 sec interval) - using primary disk
  DISK_DEV=$(lsblk -d -o NAME,TYPE | awk '$2=="disk" {print $1; exit}')
  if [ -n "$DISK_DEV" ] && [ -f "/sys/block/$DISK_DEV/stat" ]; then
    read -r _ _ CURR_READ _ _ _ _ CURR_WRITE _ < /sys/block/$DISK_DEV/stat
    CURR_READ=$((CURR_READ * 512))  # Convert sectors to bytes
    CURR_WRITE=$((CURR_WRITE * 512))
    if [ $PREV_DISK_READ -gt 0 ]; then
      READ_SPEED=$(( (CURR_READ - PREV_DISK_READ) / 5 ))
      WRITE_SPEED=$(( (CURR_WRITE - PREV_DISK_WRITE) / 5 ))
      # Format to human readable
      if [ $READ_SPEED -gt 1048576 ]; then
        DISK_READ_FMT="$(echo "scale=1; $READ_SPEED/1048576" | bc)MB"
      elif [ $READ_SPEED -gt 1024 ]; then
        DISK_READ_FMT="$(echo "scale=0; $READ_SPEED/1024" | bc)KB"
      else
        DISK_READ_FMT="${READ_SPEED}B"
      fi
      if [ $WRITE_SPEED -gt 1048576 ]; then
        DISK_WRITE_FMT="$(echo "scale=1; $WRITE_SPEED/1048576" | bc)MB"
      elif [ $WRITE_SPEED -gt 1024 ]; then
        DISK_WRITE_FMT="$(echo "scale=0; $WRITE_SPEED/1024" | bc)KB"
      else
        DISK_WRITE_FMT="${WRITE_SPEED}B"
      fi
    else
      DISK_READ_FMT="--"
      DISK_WRITE_FMT="--"
    fi
    PREV_DISK_READ=$CURR_READ
    PREV_DISK_WRITE=$CURR_WRITE
  else
    DISK_READ_FMT="--"
    DISK_WRITE_FMT="--"
  fi

  # Docker info - use sg to run with docker group
  DOCKER_RUNNING=$(sg docker -c "docker ps -q 2>/dev/null" 2>/dev/null | wc -l | tr -d '[:space:]')
  DOCKER_RUNNING=${DOCKER_RUNNING:-0}
  DOCKER_STOPPED=$(sg docker -c "docker ps -aq --filter 'status=exited' 2>/dev/null" 2>/dev/null | wc -l | tr -d '[:space:]')
  DOCKER_STOPPED=${DOCKER_STOPPED:-0}
  DOCKER_IMAGES=$(sg docker -c "docker images -q 2>/dev/null" 2>/dev/null | wc -l | tr -d '[:space:]')
  DOCKER_IMAGES=${DOCKER_IMAGES:-0}
  # Get running container details as JSON array
  DOCKER_CONTAINERS=$(sg docker -c "docker ps --format '{{.Names}}|{{.ID}}|{{.Image}}|{{.Status}}|{{.Ports}}' 2>/dev/null" 2>/dev/null | head -6 | while IFS='|' read -r name id image status ports; do
    # Escape quotes in values and truncate long strings
    image=$(echo "$image" | cut -c1-30)
    status=$(echo "$status" | sed 's/"/\\"/g')
    # Clean up ports: remove IP prefixes, normalize whitespace, and deduplicate
    ports=$(echo "$ports" | sed 's/0\.0\.0\.0://g; s/\[::\]://g' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | sort -u | paste -sd',' | sed 's/"/\\"/g' | cut -c1-60)
    echo "{\"name\":\"$name\",\"id\":\"${id:0:12}\",\"image\":\"$image\",\"status\":\"$status\",\"ports\":\"$ports\"}"
  done | paste -sd',' | sed 's/^/[/; s/$/]/')
  DOCKER_CONTAINERS=${DOCKER_CONTAINERS:-"[]"}

  # Package updates (cached, refresh every 10 min = 120 iterations)
  PKG_UPDATE_COUNT=$((PKG_UPDATE_COUNT + 1))
  if [ $PKG_UPDATE_COUNT -ge 120 ] || [ $PKG_UPDATE_COUNT -eq 1 ]; then
    PKG_UPDATES=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" | tr -d '[:space:]')
    PKG_UPDATES=${PKG_UPDATES:-0}
    PKG_UPDATE_COUNT=1
  fi

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
  "procCount": "$PROC_COUNT",
  "coreUsage": [$CORE_USAGE],
  "numCores": $NUM_CORES,
  "diskRead": "$DISK_READ_FMT",
  "diskWrite": "$DISK_WRITE_FMT",
  "dockerRunning": ${DOCKER_RUNNING:-0},
  "dockerStopped": ${DOCKER_STOPPED:-0},
  "dockerImages": ${DOCKER_IMAGES:-0},
  "dockerContainers": $DOCKER_CONTAINERS,
  "pkgUpdates": ${PKG_UPDATES:-0}
}
EOF

  # Update history file with numeric values for sparklines
  # Convert network to KB for consistent numeric storage
  if [ "$RX_FMT" = "--" ]; then
    NET_DOWN_KB=0
  elif [[ "$RX_FMT" == *MB ]]; then
    NET_DOWN_KB=$(echo "${RX_FMT%MB} * 1024" | bc | cut -d. -f1)
  elif [[ "$RX_FMT" == *KB ]]; then
    NET_DOWN_KB=${RX_FMT%KB}
  else
    NET_DOWN_KB=0
  fi

  if [ "$TX_FMT" = "--" ]; then
    NET_UP_KB=0
  elif [[ "$TX_FMT" == *MB ]]; then
    NET_UP_KB=$(echo "${TX_FMT%MB} * 1024" | bc | cut -d. -f1)
  elif [[ "$TX_FMT" == *KB ]]; then
    NET_UP_KB=${TX_FMT%KB}
  else
    NET_UP_KB=0
  fi

  # Use jq to append and trim history
  jq --argjson cpu "${CPU:-0}" \
     --argjson mem "${MEM:-0}" \
     --argjson netDown "${NET_DOWN_KB:-0}" \
     --argjson netUp "${NET_UP_KB:-0}" \
     --argjson cpuTemp "${CPU_TEMP:-0}" \
     --argjson gpuTemp "${GPU_TEMP:-0}" \
     --argjson size "$HISTORY_SIZE" \
     '.cpu = (.cpu + [$cpu])[-$size:] |
      .mem = (.mem + [$mem])[-$size:] |
      .netDown = (.netDown + [$netDown])[-$size:] |
      .netUp = (.netUp + [$netUp])[-$size:] |
      .cpuTemp = (.cpuTemp + [$cpuTemp])[-$size:] |
      .gpuTemp = (.gpuTemp + [$gpuTemp])[-$size:]' \
     "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

  sleep 5
done
