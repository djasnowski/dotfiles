# Tridactyl Config

Vim-style keyboard navigation for Firefox using [Tridactyl](https://github.com/tridactyl/tridactyl).

## Installation

1. Install [Tridactyl](https://addons.mozilla.org/en-US/firefox/addon/tridactyl-vim/) from Firefox Add-ons
2. Run `:nativeinstall` in Firefox to enable native features
3. Symlink config: `ln -s ~/dotfiles/tridactyl ~/.config/tridactyl`
4. Run `:source` in Firefox to load the config

## Theme

Custom **Matrix** theme - bright green (#00ff41) on near-black background.

## Custom New Tab Page

A Matrix-themed new tab page with live system stats, bookmarks, and keyboard shortcuts.

### Features

**Header**
- **Clock/Date** - Large time display with weekday and date
- **System Info** - Hostname, distro, kernel version
- **Keyboard Shortcuts** - Quick reference panel for Tridactyl keys

**System Monitoring**
- **CPU Cores Grid** - Per-core usage with rolling sparkline charts
- **Sparklines** - CPU, Memory, Network (↓/↑), CPU Temp, Disk I/O
- **GPU Stats** - Utilization, temperature, power draw, VRAM usage with sparklines
- **Top Processes** - Live process list sorted by CPU/memory with load averages
- **Docker Containers** - Running containers with status and ports
- **Network Interfaces** - Per-interface bandwidth with mirrored RX/TX charts
- **Tmux Sessions** - Active sessions with window lists, age, and attached indicator

**Bookmarks**
- Keyboard-accessible bookmark groups loaded from JSON
- Press number key to select group, then letter key to open link

All stats update live via the system-api service.

### Setup

1. **Start the services** (auto-start on login):
   ```bash
   # Enable systemd user services
   systemctl --user enable --now newtab-stats.service
   systemctl --user enable --now newtab-server.service
   ```

2. **Create your bookmarks**:
   ```bash
   cp ~/.config/tridactyl/newtab/bookmarks.example.json ~/.config/tridactyl/newtab/bookmarks.json
   # Edit bookmarks.json with your links
   ```

3. **Install VCR OSD Mono font** (optional, for retro look):
   ```bash
   # Download from https://www.dafont.com/vcr-osd-mono.font
   ```

### Bookmark Format

```json
[
  {
    "title": "Work",
    "links": [
      {"key": "a", "name": "Dashboard", "url": "https://example.com", "display": "example.com"}
    ]
  }
]
```

### Services

| Service | Description | Port |
|---------|-------------|------|
| `newtab-server` | HTTP server for new tab page | 8384 |
| `system-api` | FastAPI backend for system stats | 61208 |

```bash
# Check status
systemctl --user status newtab-server system-api

# View logs
journalctl --user -u system-api -f
```

## Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `j/k` | Scroll down/up |
| `h/l` | Scroll left/right |
| `gg/G` | Top/bottom of page |
| `d/u` | Half page down/up |
| `f` | Hint mode (open link) |
| `F` | Hint mode (open in new tab) |

### Tabs
| Key | Action |
|-----|--------|
| `J/K` | Previous/next tab |
| `gt/gT` | Next/previous tab |
| `d` | Close tab (move left) |
| `D` | Close tab |
| `t` | Open new tab |
| `T` | Open new background tab |
| `yd` | Duplicate tab |
| `gd` | Detach tab to window |
| `gp` | Pin/unpin tab |
| `gm` | Mute/unmute tab |
| `<<` | Move tab left |
| `>>` | Move tab right |

### Clipboard
| Key | Action |
|-----|--------|
| `yy` | Copy current URL |
| `Y` | Hint to copy link URL |
| `p` | Open clipboard URL in new tab |
| `P` | Open clipboard URL in current tab |

### Other
| Key | Action |
|-----|--------|
| `/` | Find in page |
| `n/N` | Next/previous match |
| `gr` | Reader mode |
| `gi` | Focus first input |
| `;c` | Toggle comments (Reddit/HN) |
| `;g` | Copy git clone command |

### Quickmarks
| Key | Site |
|-----|------|
| `gog` | GitHub |
| `gom` | Gmail |
| `goy` | YouTube |
| `gor` | Reddit |
| `goh` | Hacker News |

## Search Engines

Use `:open <engine> <query>` or `:tabopen <engine> <query>`

| Engine | Site |
|--------|------|
| `g` | Google |
| `ddg` | DuckDuckGo |
| `gh` | GitHub |
| `yt` | YouTube |
| `wiki` | Wikipedia |
| `mdn` | MDN Web Docs |
| `npm` | npm |
| `rs` | Rust docs |
| `py` | Python docs |

## Useful Commands

- `:help` - Open help page
- `:tutor` - Interactive tutorial
- `:source` - Reload config
- `:colours matrix` - Apply matrix theme
- `:set <key> <value>` - Change setting
- `:bind <key> <action>` - Add keybinding
