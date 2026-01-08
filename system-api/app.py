from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
import psutil
import subprocess
import socket
import platform
import time
import threading
import httpx
from collections import deque
from pynvml import (
    nvmlInit, nvmlDeviceGetHandleByIndex, nvmlDeviceGetName,
    nvmlDeviceGetTemperature, NVML_TEMPERATURE_GPU,
    nvmlDeviceGetUtilizationRates, nvmlDeviceGetMemoryInfo,
    nvmlDeviceGetPowerUsage, nvmlDeviceGetFanSpeed
)

app = FastAPI(title="System Stats API")

# CORS for newtab page
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1:8384", "http://localhost:8384"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

# Cache for rate calculations
_prev_net = {"time": 0, "sent": 0, "recv": 0}
_prev_disk = {"time": 0, "read": 0, "write": 0}

# Per-interface network tracking (btop-style) - now tracks ALL interfaces
NET_HISTORY_SIZE = 120  # 2 minutes at 1s intervals
_net_interfaces = {}  # dict of interface name -> stats dict

# Cache for static system info (doesn't change)
_system_info_cache = None

# History for sparklines (360 samples = 30 min at 5s intervals)
HISTORY_SIZE = 360
CORE_HISTORY_SIZE = 60  # 1 minute for per-core rolling charts
_history = {
    "cpu": deque(maxlen=HISTORY_SIZE),
    "mem": deque(maxlen=HISTORY_SIZE),
    "netDown": deque(maxlen=HISTORY_SIZE),
    "netUp": deque(maxlen=HISTORY_SIZE),
    "cpuTemp": deque(maxlen=HISTORY_SIZE),
    "diskIO": deque(maxlen=HISTORY_SIZE),
    # GPU metrics
    "gpuUtil": deque(maxlen=HISTORY_SIZE),
    "gpuTemp": deque(maxlen=HISTORY_SIZE),
    "gpuPower": deque(maxlen=HISTORY_SIZE),
    "gpuFan": deque(maxlen=HISTORY_SIZE),
    "gpuVram": deque(maxlen=HISTORY_SIZE),
}
# Per-core CPU history (initialized on first use)
_core_history = []  # list of deques, one per core
_history_lock = threading.Lock()


def get_system_info():
    """Get static system info (hostname, distro, kernel) - cached"""
    global _system_info_cache
    if _system_info_cache:
        return _system_info_cache

    distro = None
    try:
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    distro = line.split("=", 1)[1].strip().strip('"')
                    break
    except Exception:
        distro = platform.system()

    kernel = platform.release().split("-")[0]

    _system_info_cache = {
        "hostname": socket.gethostname(),
        "distro": distro,
        "kernel": kernel,
    }
    return _system_info_cache


def get_uptime():
    """Get system uptime as human-readable string and boot time"""
    boot_time = psutil.boot_time()
    uptime_secs = time.time() - boot_time

    days = int(uptime_secs // 86400)
    hours = int((uptime_secs % 86400) // 3600)
    minutes = int((uptime_secs % 3600) // 60)

    parts = []
    if days > 0:
        parts.append(f"{days}d")
    if hours > 0:
        parts.append(f"{hours}h")
    if minutes > 0 or not parts:
        parts.append(f"{minutes}m")

    # Format boot time as readable date
    from datetime import datetime
    boot_dt = datetime.fromtimestamp(boot_time)
    boot_str = boot_dt.strftime("%b %d, %H:%M")

    return " ".join(parts), boot_str


def get_process_count():
    """Get total number of running processes"""
    return len(list(psutil.process_iter()))


def get_process_states():
    """Count processes by state (R=running, S=sleeping, I=idle, Z=zombie, T=stopped)"""
    states = {"running": 0, "sleeping": 0, "idle": 0, "zombie": 0, "stopped": 0}
    for p in psutil.process_iter(['status']):
        try:
            status = p.info['status']
            if status == psutil.STATUS_RUNNING:
                states["running"] += 1
            elif status == psutil.STATUS_SLEEPING:
                states["sleeping"] += 1
            elif status == psutil.STATUS_IDLE:
                states["idle"] += 1
            elif status == psutil.STATUS_ZOMBIE:
                states["zombie"] += 1
            elif status in (psutil.STATUS_STOPPED, psutil.STATUS_TRACING_STOP):
                states["stopped"] += 1
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return states


def get_thread_count():
    """Get total thread count across all processes"""
    total = 0
    for p in psutil.process_iter(['num_threads']):
        try:
            total += p.info['num_threads'] or 0
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return total


# Cache for rate-based stats (ctx switches, interrupts)
_prev_cpu_stats = {"time": 0, "ctx_switches": 0, "interrupts": 0, "soft_interrupts": 0}


def get_cpu_stats_rates():
    """Get context switches/s, interrupts/s, and soft interrupts/s"""
    global _prev_cpu_stats
    now = time.time()
    stats = psutil.cpu_stats()

    if _prev_cpu_stats["time"] == 0:
        _prev_cpu_stats = {
            "time": now,
            "ctx_switches": stats.ctx_switches,
            "interrupts": stats.interrupts,
            "soft_interrupts": stats.soft_interrupts,
        }
        return {"ctx_per_sec": 0, "irq_per_sec": 0, "softirq_per_sec": 0}

    elapsed = now - _prev_cpu_stats["time"]
    if elapsed < 0.1:
        elapsed = 0.1

    ctx_per_sec = int((stats.ctx_switches - _prev_cpu_stats["ctx_switches"]) / elapsed)
    irq_per_sec = int((stats.interrupts - _prev_cpu_stats["interrupts"]) / elapsed)
    softirq_per_sec = int((stats.soft_interrupts - _prev_cpu_stats["soft_interrupts"]) / elapsed)

    _prev_cpu_stats = {
        "time": now,
        "ctx_switches": stats.ctx_switches,
        "interrupts": stats.interrupts,
        "soft_interrupts": stats.soft_interrupts,
    }

    return {
        "ctx_per_sec": max(0, ctx_per_sec),
        "irq_per_sec": max(0, irq_per_sec),
        "softirq_per_sec": max(0, softirq_per_sec),
    }


def get_cpu_times_pct():
    """Get IO wait % and softirq % from CPU times"""
    times = psutil.cpu_times_percent(interval=0)
    return {
        "iowait_pct": round(getattr(times, 'iowait', 0), 1),
        "softirq_pct": round(getattr(times, 'softirq', 0), 1),
    }


def get_all_temps():
    """Get all temperatures including motherboard sensors"""
    temps = {
        "cpu_temp_c": None,
        "pch_temp_c": None,
        "vrm_temp_c": None,
        "nvme_temp_c": None,
    }

    try:
        sensors = psutil.sensors_temperatures()

        # CPU temp (k10temp for AMD, coretemp for Intel)
        for name in ["k10temp", "coretemp", "zenpower", "cpu_thermal"]:
            if name in sensors and sensors[name]:
                for s in sensors[name]:
                    if s.label in ["Tctl", "Tdie", "Package id 0", ""]:
                        temps["cpu_temp_c"] = s.current
                        break
                if temps["cpu_temp_c"] is None:
                    temps["cpu_temp_c"] = max(s.current for s in sensors[name])
                break

        # Gigabyte motherboard sensors (B650)
        if "gigabyte_wmi" in sensors:
            gb_temps = sensors["gigabyte_wmi"]
            if len(gb_temps) > 2:
                temps["pch_temp_c"] = gb_temps[2].current
            if len(gb_temps) > 4:
                temps["vrm_temp_c"] = gb_temps[4].current

        # NVMe temps - average all NVMe drives
        nvme_temps = []
        for name in sensors:
            if "nvme" in name.lower():
                for s in sensors[name]:
                    if "composite" in s.label.lower() or s.label == "":
                        nvme_temps.append(s.current)
                        break
        if nvme_temps:
            temps["nvme_temp_c"] = round(sum(nvme_temps) / len(nvme_temps), 2)

    except Exception:
        pass

    return temps


def get_gpu():
    try:
        nvmlInit()
        h = nvmlDeviceGetHandleByIndex(0)
        util = nvmlDeviceGetUtilizationRates(h)
        mem = nvmlDeviceGetMemoryInfo(h)
        name = nvmlDeviceGetName(h)
        if isinstance(name, bytes):
            name = name.decode("utf-8", "ignore")
        return {
            "name": name,
            "util_gpu_pct": util.gpu,
            "temp_c": nvmlDeviceGetTemperature(h, NVML_TEMPERATURE_GPU),
            "power_w": round(nvmlDeviceGetPowerUsage(h) / 1000, 1),
            "fan_pct": nvmlDeviceGetFanSpeed(h),
            "vram_used_mb": int(mem.used / (1024 * 1024)),
            "vram_total_mb": int(mem.total / (1024 * 1024)),
        }
    except Exception as e:
        return {"error": str(e)}


def get_gpu_processes():
    """Get processes using GPU via nvidia-smi (both compute and graphics)"""
    try:
        # Use pmon to get all GPU processes (compute + graphics)
        result = subprocess.run(
            ["nvidia-smi", "pmon", "-c", "1", "-s", "m"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            return []

        gpu_procs = []
        seen_pids = set()
        for line in result.stdout.strip().split("\n"):
            if line.startswith("#") or not line.strip():
                continue
            parts = line.split()
            if len(parts) >= 4:
                try:
                    pid = int(parts[1])
                    if pid in seen_pids or pid == 0:
                        continue
                    seen_pids.add(pid)
                    # Get memory usage from nvidia-smi for this PID
                    mem_result = subprocess.run(
                        ["nvidia-smi", "--query-compute-apps=pid,used_gpu_memory",
                         "--format=csv,noheader,nounits"],
                        capture_output=True, text=True, timeout=2
                    )
                    gpu_mem = 0
                    for mem_line in mem_result.stdout.strip().split("\n"):
                        if mem_line.strip():
                            mem_parts = [p.strip() for p in mem_line.split(",")]
                            if len(mem_parts) >= 2 and int(mem_parts[0]) == pid:
                                gpu_mem = int(mem_parts[1])
                                break

                    p = psutil.Process(pid)
                    gpu_procs.append({
                        "pid": pid,
                        "name": p.name(),
                        "gpu_mem_mb": gpu_mem,
                        "user": p.username(),
                    })
                except (psutil.NoSuchProcess, psutil.AccessDenied, ValueError):
                    pass
        return gpu_procs
    except Exception:
        return []


def format_elapsed(secs):
    """Format elapsed seconds as friendly string"""
    if secs < 60:
        return f"{int(secs)}s"
    elif secs < 3600:
        return f"{int(secs // 60)}m"
    elif secs < 86400:
        hours = int(secs // 3600)
        mins = int((secs % 3600) // 60)
        return f"{hours}h {mins}m" if mins else f"{hours}h"
    else:
        days = int(secs // 86400)
        hours = int((secs % 86400) // 3600)
        return f"{days}d {hours}h" if hours else f"{days}d"


def get_top_processes(limit=30, sort_by="cpu"):
    procs = []
    now = time.time()
    for p in psutil.process_iter(["pid", "username", "name", "cpu_percent", "memory_info", "create_time"]):
        try:
            info = p.info
            rss = info["memory_info"].rss if info.get("memory_info") else 0
            create_time = info.get("create_time", now)
            elapsed_secs = now - create_time
            procs.append({
                "pid": info["pid"],
                "user": info.get("username"),
                "name": info.get("name"),
                "cpu_pct": info.get("cpu_percent", 0.0),
                "rss_mb": int(rss / (1024 * 1024)),
                "elapsed": format_elapsed(elapsed_secs),
            })
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass

    sort_key = {"cpu": "cpu_pct", "mem": "rss_mb"}.get(sort_by, "cpu_pct")
    procs.sort(key=lambda x: x.get(sort_key, 0), reverse=True)
    return procs[:limit]


def get_net_rates():
    """Calculate network transfer rates in KB/s"""
    global _prev_net
    now = time.time()
    counters = psutil.net_io_counters()

    if _prev_net["time"] == 0:
        _prev_net = {"time": now, "sent": counters.bytes_sent, "recv": counters.bytes_recv}
        return {"up_kb_s": 0.0, "down_kb_s": 0.0, "bytes_sent_total": counters.bytes_sent, "bytes_recv_total": counters.bytes_recv}

    elapsed = now - _prev_net["time"]
    if elapsed < 0.1:
        elapsed = 0.1

    up_kb_s = round((counters.bytes_sent - _prev_net["sent"]) / 1024 / elapsed, 1)
    down_kb_s = round((counters.bytes_recv - _prev_net["recv"]) / 1024 / elapsed, 1)

    _prev_net = {"time": now, "sent": counters.bytes_sent, "recv": counters.bytes_recv}

    return {
        "up_kb_s": max(0, up_kb_s),
        "down_kb_s": max(0, down_kb_s),
        "bytes_sent_total": counters.bytes_sent,
        "bytes_recv_total": counters.bytes_recv,
    }


def get_net_interface_stats():
    """Get per-interface network stats for ALL active interfaces (btop-style)"""
    global _net_interfaces
    import os
    import socket
    import struct
    import fcntl

    now = time.time()
    results = []

    # Find all active interfaces
    try:
        ifaces = os.listdir("/sys/class/net")
    except Exception:
        return {"interfaces": [], "err": "cannot list interfaces"}

    for iface in ifaces:
        # Skip docker veth interfaces (virtual endpoints)
        if iface.startswith("veth"):
            continue

        # Check if interface is up (lo shows "unknown" but is always up)
        try:
            state_path = f"/sys/class/net/{iface}/operstate"
            with open(state_path) as f:
                state = f.read().strip()
                if state not in ("up", "unknown"):
                    continue
        except Exception:
            continue

        # Read bytes from sysfs
        try:
            with open(f"/sys/class/net/{iface}/statistics/rx_bytes") as f:
                rx_bytes = int(f.read().strip())
            with open(f"/sys/class/net/{iface}/statistics/tx_bytes") as f:
                tx_bytes = int(f.read().strip())
        except Exception:
            continue

        # Get IP address
        ip = "--"
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            ip = socket.inet_ntoa(fcntl.ioctl(
                s.fileno(),
                0x8915,  # SIOCGIFADDR
                struct.pack('256s', iface.encode()[:15])
            )[20:24])
            s.close()
        except Exception:
            pass

        # Initialize tracking for this interface if needed
        if iface not in _net_interfaces:
            _net_interfaces[iface] = {
                "time": now,
                "rx_bytes": rx_bytes,
                "tx_bytes": tx_bytes,
                "rx_Bps": 0,
                "tx_Bps": 0,
                "rx_peak_Bps": 0,
                "tx_peak_Bps": 0,
                "rx_hist": deque(maxlen=NET_HISTORY_SIZE),
                "tx_hist": deque(maxlen=NET_HISTORY_SIZE),
            }

        cached = _net_interfaces[iface]
        elapsed = now - cached["time"]

        if elapsed >= 0.1:
            # Calculate bytes per second
            rx_Bps = max(0, int((rx_bytes - cached["rx_bytes"]) / elapsed))
            tx_Bps = max(0, int((tx_bytes - cached["tx_bytes"]) / elapsed))

            # Update peaks
            if rx_Bps > cached["rx_peak_Bps"]:
                cached["rx_peak_Bps"] = rx_Bps
            if tx_Bps > cached["tx_peak_Bps"]:
                cached["tx_peak_Bps"] = tx_Bps

            # Record history
            cached["rx_hist"].append(rx_Bps)
            cached["tx_hist"].append(tx_Bps)

            # Update cache
            cached.update({
                "time": now,
                "rx_bytes": rx_bytes,
                "tx_bytes": tx_bytes,
                "rx_Bps": rx_Bps,
                "tx_Bps": tx_Bps,
            })
        else:
            rx_Bps = cached["rx_Bps"]
            tx_Bps = cached["tx_Bps"]

        results.append({
            "iface": iface,
            "ip": ip,
            "rx_Bps": rx_Bps,
            "tx_Bps": tx_Bps,
            "rx_peak_Bps": cached["rx_peak_Bps"],
            "tx_peak_Bps": cached["tx_peak_Bps"],
            "rx_total_bytes": rx_bytes,
            "tx_total_bytes": tx_bytes,
            "rx_hist_Bps": list(cached["rx_hist"]),
            "tx_hist_Bps": list(cached["tx_hist"]),
        })

    # Sort: wired first, then wireless, then bridges, then loopback
    def sort_key(x):
        name = x["iface"]
        if name.startswith("enp") or name.startswith("eth"):
            return (0, name)
        elif name.startswith("wl"):
            return (1, name)
        elif name.startswith("br-"):
            return (2, name)
        elif name == "lo":
            return (4, name)
        else:
            return (3, name)

    results.sort(key=sort_key)

    return {"interfaces": results}


def get_disk_io_rates():
    """Calculate disk I/O rates in MB/s"""
    global _prev_disk
    now = time.time()

    try:
        counters = psutil.disk_io_counters()
    except Exception:
        return {"read_mb_s": 0.0, "write_mb_s": 0.0}

    if _prev_disk["time"] == 0:
        _prev_disk = {"time": now, "read": counters.read_bytes, "write": counters.write_bytes}
        return {"read_mb_s": 0.0, "write_mb_s": 0.0, "read_bytes_total": counters.read_bytes, "write_bytes_total": counters.write_bytes}

    elapsed = now - _prev_disk["time"]
    if elapsed < 0.1:
        elapsed = 0.1

    read_mb_s = round((counters.read_bytes - _prev_disk["read"]) / (1024 * 1024) / elapsed, 2)
    write_mb_s = round((counters.write_bytes - _prev_disk["write"]) / (1024 * 1024) / elapsed, 2)

    _prev_disk = {"time": now, "read": counters.read_bytes, "write": counters.write_bytes}

    return {
        "read_mb_s": max(0, read_mb_s),
        "write_mb_s": max(0, write_mb_s),
        "read_bytes_total": counters.read_bytes,
        "write_bytes_total": counters.write_bytes,
    }


def get_all_disks():
    """Get usage for all mounted partitions"""
    disks = []
    for part in psutil.disk_partitions(all=False):
        if part.fstype and not part.mountpoint.startswith(("/snap", "/boot/efi")):
            try:
                usage = psutil.disk_usage(part.mountpoint)
                disks.append({
                    "mount": part.mountpoint,
                    "device": part.device,
                    "fstype": part.fstype,
                    "total_gb": round(usage.total / (1024**3), 2),
                    "used_gb": round(usage.used / (1024**3), 2),
                    "free_gb": round(usage.free / (1024**3), 2),
                    "util_pct": usage.percent,
                })
            except (PermissionError, OSError):
                pass
    return disks


def get_battery():
    """Get battery info if available"""
    try:
        bat = psutil.sensors_battery()
        if bat:
            return {
                "percent": bat.percent,
                "plugged": bat.power_plugged,
                "secs_left": bat.secsleft if bat.secsleft > 0 else None,
            }
    except Exception:
        pass
    return None


def get_swap():
    """Get swap memory usage"""
    swap = psutil.swap_memory()
    return {
        "total_mb": int(swap.total / (1024 * 1024)),
        "used_mb": int(swap.used / (1024 * 1024)),
        "free_mb": int(swap.free / (1024 * 1024)),
        "util_pct": swap.percent,
    }


def get_connections():
    """Get network connection counts"""
    try:
        conns = psutil.net_connections(kind='inet')
        established = sum(1 for c in conns if c.status == 'ESTABLISHED')
        listening = sum(1 for c in conns if c.status == 'LISTEN')
        return {
            "total": len(conns),
            "established": established,
            "listening": listening,
        }
    except (psutil.AccessDenied, PermissionError):
        return {"total": 0, "established": 0, "listening": 0}


def get_docker():
    """Get Docker container info"""
    try:
        running = subprocess.run(
            ["sg", "docker", "-c", "docker ps -q"],
            capture_output=True, text=True, timeout=5
        )
        running_count = len(running.stdout.strip().split("\n")) if running.stdout.strip() else 0

        stopped = subprocess.run(
            ["sg", "docker", "-c", "docker ps -aq --filter status=exited"],
            capture_output=True, text=True, timeout=5
        )
        stopped_count = len(stopped.stdout.strip().split("\n")) if stopped.stdout.strip() else 0

        images = subprocess.run(
            ["sg", "docker", "-c", "docker images -q"],
            capture_output=True, text=True, timeout=5
        )
        images_count = len(images.stdout.strip().split("\n")) if images.stdout.strip() else 0

        containers = []
        result = subprocess.run(
            ["sg", "docker", "-c", "docker ps --format '{{.Names}}|{{.ID}}|{{.Image}}|{{.Status}}|{{.Ports}}'"],
            capture_output=True, text=True, timeout=5
        )
        if result.stdout.strip():
            for line in result.stdout.strip().split("\n")[:6]:
                parts = line.split("|")
                if len(parts) >= 5:
                    ports = parts[4].replace("0.0.0.0:", "").replace("[::]:", "")
                    containers.append({
                        "name": parts[0],
                        "id": parts[1][:12],
                        "image": parts[2][:30],
                        "status": parts[3],
                        "ports": ports[:60],
                    })

        return {
            "running": running_count,
            "stopped": stopped_count,
            "images": images_count,
            "containers": containers,
        }
    except Exception:
        return {
            "running": 0,
            "stopped": 0,
            "images": 0,
            "containers": [],
        }


def format_bytes_rate(kb_s):
    """Format KB/s to human readable string"""
    if kb_s >= 1024:
        return f"{kb_s / 1024:.1f}MB"
    elif kb_s >= 1:
        return f"{int(kb_s)}KB"
    else:
        return "0"


def record_history(cpu_pct, mem_pct, net_down_kb, net_up_kb, cpu_temp, disk_io_kb,
                   gpu_util=0, gpu_temp=0, gpu_power=0, gpu_fan=0, gpu_vram_pct=0,
                   per_core_pct=None):
    """Record a history sample for sparklines"""
    global _core_history
    with _history_lock:
        _history["cpu"].append(cpu_pct)
        _history["mem"].append(mem_pct)
        _history["netDown"].append(net_down_kb)
        _history["netUp"].append(net_up_kb)
        _history["cpuTemp"].append(cpu_temp or 0)
        _history["diskIO"].append(disk_io_kb)
        # GPU metrics
        _history["gpuUtil"].append(gpu_util or 0)
        _history["gpuTemp"].append(gpu_temp or 0)
        _history["gpuPower"].append(gpu_power or 0)
        _history["gpuFan"].append(gpu_fan or 0)
        _history["gpuVram"].append(gpu_vram_pct or 0)
        # Per-core CPU history
        if per_core_pct:
            # Initialize core history deques if needed
            while len(_core_history) < len(per_core_pct):
                _core_history.append(deque(maxlen=CORE_HISTORY_SIZE))
            for i, pct in enumerate(per_core_pct):
                _core_history[i].append(pct)


def get_history_snapshot():
    """Get current history as lists"""
    with _history_lock:
        return {
            "cpu": list(_history["cpu"]),
            "mem": list(_history["mem"]),
            "netDown": list(_history["netDown"]),
            "netUp": list(_history["netUp"]),
            "cpuTemp": list(_history["cpuTemp"]),
            "diskIO": list(_history["diskIO"]),
            # GPU metrics
            "gpuUtil": list(_history["gpuUtil"]),
            "gpuTemp": list(_history["gpuTemp"]),
            "gpuPower": list(_history["gpuPower"]),
            "gpuFan": list(_history["gpuFan"]),
            "gpuVram": list(_history["gpuVram"]),
            # Per-core CPU history
            "perCore": [list(core) for core in _core_history],
        }


@app.get("/api/v1/snapshot")
def snapshot():
    vm = psutil.virtual_memory()
    temps = get_all_temps()
    sys_info = get_system_info()
    net = get_net_rates()
    disk_io = get_disk_io_rates()
    gpu = get_gpu()
    cpu_times = get_cpu_times_pct()
    cpu_stats = get_cpu_stats_rates()

    cpu_pct = psutil.cpu_percent(interval=0.2)
    per_core_pct = psutil.cpu_percent(interval=0, percpu=True)
    mem_pct = vm.percent

    # Record history
    disk_io_kb = int((disk_io.get("read_mb_s", 0) + disk_io.get("write_mb_s", 0)) * 1024)
    gpu_vram_pct = 0
    if isinstance(gpu, dict) and gpu.get("vram_total_mb"):
        gpu_vram_pct = round(gpu.get("vram_used_mb", 0) / gpu["vram_total_mb"] * 100, 1)
    record_history(
        cpu_pct=cpu_pct,
        mem_pct=mem_pct,
        net_down_kb=net["down_kb_s"],
        net_up_kb=net["up_kb_s"],
        cpu_temp=temps["cpu_temp_c"],
        disk_io_kb=disk_io_kb,
        gpu_util=gpu.get("util_gpu_pct", 0) if isinstance(gpu, dict) else 0,
        gpu_temp=gpu.get("temp_c", 0) if isinstance(gpu, dict) else 0,
        gpu_power=gpu.get("power_w", 0) if isinstance(gpu, dict) else 0,
        gpu_fan=gpu.get("fan_pct", 0) if isinstance(gpu, dict) else 0,
        gpu_vram_pct=gpu_vram_pct,
        per_core_pct=per_core_pct,
    )

    return {
        "system": {
            "hostname": sys_info["hostname"],
            "distro": sys_info["distro"],
            "kernel": sys_info["kernel"],
            "uptime": get_uptime()[0],
            "boot_time": get_uptime()[1],
            "proc_count": get_process_count(),
            "proc_states": get_process_states(),
        },
        "cpu": {
            "util_pct": cpu_pct,
            "per_core_pct": per_core_pct,
            "load_avg": list(psutil.getloadavg()),
            "count": psutil.cpu_count(),
            "count_physical": psutil.cpu_count(logical=False),
            "temp_c": temps["cpu_temp_c"],
            "iowait_pct": cpu_times["iowait_pct"],
            "softirq_pct": cpu_times["softirq_pct"],
            "ctx_per_sec": cpu_stats["ctx_per_sec"],
            "irq_per_sec": cpu_stats["irq_per_sec"],
            "thread_count": get_thread_count(),
        },
        "temps": {
            "cpu_c": temps["cpu_temp_c"],
            "pch_c": temps["pch_temp_c"],
            "vrm_c": temps["vrm_temp_c"],
            "nvme_c": temps["nvme_temp_c"],
        },
        "mem": {
            "total_mb": int(vm.total / (1024 * 1024)),
            "used_mb": int(vm.used / (1024 * 1024)),
            "available_mb": int(vm.available / (1024 * 1024)),
            "cached_mb": int(getattr(vm, 'cached', 0) / (1024 * 1024)),
            "util_pct": mem_pct,
        },
        "swap": get_swap(),
        "disks": get_all_disks(),
        "disk_io": disk_io,
        "net": net,
        "gpu": gpu,
        "docker": get_docker(),
        "battery": get_battery(),
        "connections": get_connections(),
        "processes": get_top_processes(),
        "gpu_processes": get_gpu_processes(),
    }


@app.get("/api/v1/history")
def history():
    """Get sparkline history data"""
    return get_history_snapshot()


@app.get("/api/v1/net")
def net():
    """Get per-interface network stats (btop-style)"""
    return get_net_interface_stats()


@app.get("/api/v1/top")
def top(
    sort: str = Query("cpu", pattern="^(cpu|mem|gpu_mem)$"),
    limit: int = Query(30, ge=1, le=100)
):
    """btop-like process list sorted by cpu, mem, or gpu_mem"""
    if sort == "gpu_mem":
        procs = get_gpu_processes()
        procs.sort(key=lambda x: x.get("gpu_mem_mb", 0), reverse=True)
        return {"processes": procs[:limit]}
    return {"processes": get_top_processes(limit=limit, sort_by=sort)}


@app.get("/api/v1/health")
async def health_check(url: str):
    """Check if a URL is reachable and return response time"""
    try:
        async with httpx.AsyncClient(timeout=5.0, follow_redirects=True) as client:
            start = time.time()
            resp = await client.get(url)
            elapsed_ms = int((time.time() - start) * 1000)
            return {
                "url": url,
                "status": "up",
                "code": resp.status_code,
                "time_ms": elapsed_ms,
            }
    except httpx.TimeoutException:
        return {"url": url, "status": "timeout", "code": None, "time_ms": None}
    except Exception as e:
        return {"url": url, "status": "down", "code": None, "time_ms": None, "error": str(e)}


@app.get("/api/v1/app-health")
async def app_health(mode: str = Query("local", pattern="^(local|prod)$")):
    """Proxy to TitleTrackr health.json endpoint (bypasses CORS)"""
    base_url = "https://app.titletrackr.com" if mode == "prod" else "http://localhost"
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            resp = await client.get(f"{base_url}/health.json")
            return resp.json()
    except httpx.TimeoutException:
        return {"error": "timeout", "checkResults": []}
    except Exception as e:
        return {"error": str(e), "checkResults": []}


@app.get("/api/v1/app-abstracts")
async def app_abstracts(mode: str = Query("local", pattern="^(local|prod)$")):
    """Proxy to TitleTrackr abstracts.json endpoint (bypasses CORS)"""
    base_url = "https://app.titletrackr.com" if mode == "prod" else "http://localhost"
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            resp = await client.get(f"{base_url}/abstracts.json")
            return resp.json()
    except httpx.TimeoutException:
        return {"error": "timeout", "abstracts": []}
    except Exception as e:
        return {"error": str(e), "abstracts": []}


@app.get("/api/v1/search-agent-health")
async def search_agent_health(mode: str = Query("local", pattern="^(local|prod)$")):
    """Proxy to search agent health endpoint"""
    base_url = "http://search-agents.titletrackr.com:8080" if mode == "prod" else "http://localhost:3001"
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            resp = await client.get(f"{base_url}/health")
            return resp.json()
    except httpx.TimeoutException:
        return {"error": "timeout", "worker": {"status": "unknown"}}
    except Exception as e:
        return {"error": str(e), "worker": {"status": "unknown"}}


@app.get("/api/v1/tmux")
def tmux_sessions():
    """Get tmux sessions with windows info"""
    try:
        # Get sessions: name, windows count, attached status, created time
        result = subprocess.run(
            ["tmux", "list-sessions", "-F", "#{session_name}|#{session_windows}|#{?session_attached,1,0}|#{session_created}"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            return {"sessions": [], "error": "no tmux server"}

        sessions = []
        for line in result.stdout.strip().split("\n"):
            if not line.strip():
                continue
            parts = line.split("|")
            if len(parts) >= 4:
                name = parts[0]
                windows = int(parts[1])
                attached = parts[2] == "1"
                created = int(parts[3])

                # Get window names for this session
                win_result = subprocess.run(
                    ["tmux", "list-windows", "-t", name, "-F", "#{window_index}:#{window_name}"],
                    capture_output=True, text=True, timeout=2
                )
                window_list = []
                if win_result.returncode == 0:
                    for win_line in win_result.stdout.strip().split("\n"):
                        if win_line.strip():
                            window_list.append(win_line.strip())

                sessions.append({
                    "name": name,
                    "windows": windows,
                    "window_list": window_list[:6],  # Limit to 6 windows
                    "attached": attached,
                    "created": created,
                    "age": format_elapsed(time.time() - created),
                })

        return {"sessions": sessions}
    except FileNotFoundError:
        return {"sessions": [], "error": "tmux not installed"}
    except Exception as e:
        return {"sessions": [], "error": str(e)}
