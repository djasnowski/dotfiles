from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
import psutil
import subprocess
import socket
import platform
import time
import threading
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

# Cache for static system info (doesn't change)
_system_info_cache = None

# History for sparklines (360 samples = 30 min at 5s intervals)
HISTORY_SIZE = 360
_history = {
    "cpu": deque(maxlen=HISTORY_SIZE),
    "mem": deque(maxlen=HISTORY_SIZE),
    "netDown": deque(maxlen=HISTORY_SIZE),
    "netUp": deque(maxlen=HISTORY_SIZE),
    "cpuTemp": deque(maxlen=HISTORY_SIZE),
    "gpuTemp": deque(maxlen=HISTORY_SIZE),
    "diskIO": deque(maxlen=HISTORY_SIZE),
}
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
    """Get system uptime as human-readable string"""
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

    return " ".join(parts)


def get_process_count():
    """Get total number of running processes"""
    return len(list(psutil.process_iter()))


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
    """Get processes using GPU via nvidia-smi"""
    try:
        result = subprocess.run(
            ["nvidia-smi", "--query-compute-apps=pid,process_name,used_gpu_memory",
             "--format=csv,noheader,nounits"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode != 0:
            return []

        gpu_procs = []
        for line in result.stdout.strip().split("\n"):
            if not line.strip():
                continue
            parts = [p.strip() for p in line.split(",")]
            if len(parts) >= 3:
                pid = int(parts[0])
                try:
                    p = psutil.Process(pid)
                    gpu_procs.append({
                        "pid": pid,
                        "name": parts[1],
                        "gpu_mem_mb": int(parts[2]),
                        "user": p.username(),
                        "cpu_pct": p.cpu_percent(),
                        "rss_mb": int(p.memory_info().rss / (1024 * 1024)),
                    })
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    gpu_procs.append({
                        "pid": pid,
                        "name": parts[1],
                        "gpu_mem_mb": int(parts[2]),
                    })
        return gpu_procs
    except Exception:
        return []


def get_top_processes(limit=30, sort_by="cpu"):
    procs = []
    for p in psutil.process_iter(["pid", "username", "name", "cpu_percent", "memory_info", "create_time"]):
        try:
            info = p.info
            rss = info["memory_info"].rss if info.get("memory_info") else 0
            procs.append({
                "pid": info["pid"],
                "user": info.get("username"),
                "name": info.get("name"),
                "cpu_pct": info.get("cpu_percent", 0.0),
                "rss_mb": int(rss / (1024 * 1024)),
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


def record_history(cpu_pct, mem_pct, net_down_kb, net_up_kb, cpu_temp, gpu_temp, disk_io_kb):
    """Record a history sample for sparklines"""
    with _history_lock:
        _history["cpu"].append(cpu_pct)
        _history["mem"].append(mem_pct)
        _history["netDown"].append(net_down_kb)
        _history["netUp"].append(net_up_kb)
        _history["cpuTemp"].append(cpu_temp or 0)
        _history["gpuTemp"].append(gpu_temp or 0)
        _history["diskIO"].append(disk_io_kb)


def get_history_snapshot():
    """Get current history as lists"""
    with _history_lock:
        return {
            "cpu": list(_history["cpu"]),
            "mem": list(_history["mem"]),
            "netDown": list(_history["netDown"]),
            "netUp": list(_history["netUp"]),
            "cpuTemp": list(_history["cpuTemp"]),
            "gpuTemp": list(_history["gpuTemp"]),
            "diskIO": list(_history["diskIO"]),
        }


@app.get("/api/v1/snapshot")
def snapshot():
    vm = psutil.virtual_memory()
    temps = get_all_temps()
    sys_info = get_system_info()
    net = get_net_rates()
    disk_io = get_disk_io_rates()
    gpu = get_gpu()

    cpu_pct = psutil.cpu_percent(interval=0.2)
    mem_pct = vm.percent

    # Record history
    gpu_temp = gpu.get("temp_c") if isinstance(gpu, dict) else None
    disk_io_kb = int((disk_io.get("read_mb_s", 0) + disk_io.get("write_mb_s", 0)) * 1024)
    record_history(
        cpu_pct=cpu_pct,
        mem_pct=mem_pct,
        net_down_kb=net["down_kb_s"],
        net_up_kb=net["up_kb_s"],
        cpu_temp=temps["cpu_temp_c"],
        gpu_temp=gpu_temp,
        disk_io_kb=disk_io_kb,
    )

    return {
        "system": {
            "hostname": sys_info["hostname"],
            "distro": sys_info["distro"],
            "kernel": sys_info["kernel"],
            "uptime": get_uptime(),
            "proc_count": get_process_count(),
        },
        "cpu": {
            "util_pct": cpu_pct,
            "per_core_pct": psutil.cpu_percent(interval=0, percpu=True),
            "load_avg": list(psutil.getloadavg()),
            "count": psutil.cpu_count(),
            "count_physical": psutil.cpu_count(logical=False),
            "temp_c": temps["cpu_temp_c"],
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
        "processes": get_top_processes(),
        "gpu_processes": get_gpu_processes(),
    }


@app.get("/api/v1/history")
def history():
    """Get sparkline history data"""
    return get_history_snapshot()


@app.get("/api/v1/top")
def top(
    sort: str = Query("cpu", regex="^(cpu|mem|gpu_mem)$"),
    limit: int = Query(30, ge=1, le=100)
):
    """btop-like process list sorted by cpu, mem, or gpu_mem"""
    if sort == "gpu_mem":
        procs = get_gpu_processes()
        procs.sort(key=lambda x: x.get("gpu_mem_mb", 0), reverse=True)
        return {"processes": procs[:limit]}
    return {"processes": get_top_processes(limit=limit, sort_by=sort)}
