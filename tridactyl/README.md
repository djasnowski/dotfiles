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
- **Clock/Date** - Centered time display
- **System Info** - Hostname, distro, kernel, load avg, process count
- **Bookmarks** - Keyboard-accessible links loaded from JSON
- **Keyboard Shortcuts** - Quick reference panel
- **Live Stats** - CPU, GPU, RAM, disk, temps, network, uptime (updates every 5s)

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
| `newtab-server` | HTTP server for new tab | 8384 |
| `newtab-stats` | Stats collector (JSON) | - |

```bash
# Check status
systemctl --user status newtab-stats newtab-server

# View logs
journalctl --user -u newtab-stats -f
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
