# Dotfiles - Ubuntu i3 Setup

A Matrix-themed, keyboard-driven desktop environment for Ubuntu featuring i3 window manager, Polybar, and a comprehensive development workflow.

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Components](#components)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration Details](#configuration-details)
- [Keybindings](#keybindings)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## Overview

This is a complete desktop environment configuration optimized for:
- **Keyboard-driven workflow** with vim-style navigation throughout
- **Multi-monitor support** with automatic display detection
- **Matrix aesthetic** with green-on-black color scheme
- **Development-focused** with extensive aliases and tool integrations
- **Spotify integration** with custom controls and status display

### Key Features

- **i3 Window Manager**: Tiling window manager with custom keybindings
- **Polybar**: Multi-bar setup with system stats, weather, and Spotify integration
- **Rofi**: Application launcher and power menu with Matrix theme
- **Dunst**: Notification daemon styled to match the Matrix theme
- **XFCE4 Terminal**: Custom color scheme and JetBrains Mono Nerd Font
- **Zsh + Oh-My-Zsh**: Shell with Spaceship theme and extensive aliases
- **Tmux**: Terminal multiplexer with vim-style navigation
- **Tridactyl**: Vim bindings for Firefox

## Components

### Window Manager & Desktop Environment

| Component | Purpose | Config Location |
|-----------|---------|----------------|
| **i3** | Tiling window manager | `i3/config` |
| **Polybar** | Status bar | `polybar/` |
| **Rofi** | Application launcher | `rofi/` |
| **Dunst** | Notification daemon | `dunst/dunstrc` |
| **Feh** | Wallpaper setter | Used in i3 config |

### Terminal & Shell

| Component | Purpose | Config Location |
|-----------|---------|----------------|
| **XFCE4 Terminal** | Terminal emulator | `xfce4/terminal/terminalrc` |
| **Zsh** | Shell | `.zshrc` |
| **Oh-My-Zsh** | Zsh framework | Referenced in `.zshrc` |
| **Spaceship** | Zsh theme | Referenced in `.zshrc` |
| **Tmux** | Terminal multiplexer | `.tmux.conf` |

### Browser & Extensions

| Component | Purpose | Config Location |
|-----------|---------|----------------|
| **Tridactyl** | Firefox vim bindings | `tridactyl/tridactylrc` |

### Music & Media

| Component | Purpose | Config Location |
|-----------|---------|----------------|
| **ncspot** | Terminal-based Spotify client | Flatpak (alias: `spt`) |
| **Spotify** | Desktop Spotify client | Flatpak (alias: `spot`) |
| **playerctl** | Media player controller | Used for keyboard shortcuts |

### Custom Scripts

| Script | Purpose | Location |
|--------|---------|----------|
| **auto-display.sh** | Auto-detect and configure monitors | `i3/auto-display.sh` |
| **power-menu-matrix.sh** | Matrix-themed power menu | `rofi/power-menu-matrix.sh` |
| **Spotify scripts** | Spotify integration for Polybar | `scripts/spotify/` |
| **Weather scripts** | Weather display for Polybar | `polybar/scripts/weather*.sh` |

## Prerequisites

### Required Packages

```bash
# Core window manager and desktop components
sudo apt update
sudo apt install -y \
    i3 \
    polybar \
    rofi \
    dunst \
    feh \
    xfce4-terminal \
    flameshot \
    playerctl \
    jq

# Fonts
sudo apt install -y \
    fonts-dejavu \
    fonts-font-awesome

# Install JetBrains Mono Nerd Font manually from:
# https://github.com/ryanoasis/nerd-fonts/releases

# Shell and terminal tools
sudo apt install -y \
    zsh \
    tmux \
    git \
    curl \
    wget

# Development tools
sudo apt install -y \
    build-essential \
    ripgrep \
    bat \
    lazygit

# Optional: Display management
sudo apt install -y \
    xrandr \
    arandr
```

### Additional Dependencies

```bash
# Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Spaceship theme for Zsh
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Tmux Plugin Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# FNM (Fast Node Manager)
curl -fsSL https://fnm.vercel.app/install | bash

# Optional: Bun
curl -fsSL https://bun.sh/install | bash

# Optional: pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

### Flatpak Applications (Manual Install)

**Important**: Make sure you follow the [Flatpak setup guide](https://flatpak.org/setup/) for your Linux distribution before installing applications.

```bash
# Install Flatpak
sudo apt install flatpak

# Add the Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Restart your system (or log out/in) to complete Flatpak setup
# Then install applications:

# ncspot - Terminal-based Spotify client (aliased as 'spt')
flatpak install flathub io.github.hrkfdn.ncspot

# Spotify Desktop Client (aliased as 'spot')
flatpak install flathub com.spotify.Client
```

**Running Flatpak applications:**
```bash
# ncspot (terminal Spotify client)
flatpak run io.github.hrkfdn.ncspot
# Or use the alias:
spt

# Spotify Desktop
flatpak run com.spotify.Client
# Or use the alias:
spot
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the Install Script

```bash
# Full install (recommended for new systems)
# Installs apt packages, oh-my-zsh, plugins, and creates symlinks
./install.sh --all

# Or install in stages:
./install.sh --deps    # Install apt packages + symlinks
./install.sh           # Only create symlinks (if deps already installed)
```

The script will:
- Install required apt packages (with `--deps` or `--all`)
- Install oh-my-zsh, spaceship theme, zsh plugins, tpm (with `--all`)
- Backup any existing configs to `~/.config/backup-YYYYMMDD-HHMMSS/`
- Create symbolic links from `~/.config/*` to `~/dotfiles/*`

### 3. Post-Install

```bash
# Set zsh as default shell
chsh -s $(which zsh)

# Install tmux plugins (inside tmux)
# Press: prefix + I
```

### 4. Install Rofi Themes

```bash
# The Matrix theme is referenced in rofi config
# Make sure the theme file exists at:
# ~/.local/share/rofi/themes/matrix.rasi
# Or update the path in rofi/config.rasi
```

### 5. Set Up Wallpaper

```bash
# Place your Matrix wallpaper at:
mkdir -p ~/Documents
# Download or copy your matrix-wallpaper.png to ~/Documents/
# Or update the path in i3/config line 200
```

### 6. Reload Configurations

```bash
# Reload i3
i3-msg reload
# Or restart i3
i3-msg restart

# Reload tmux (if already running)
tmux source ~/.tmux.conf
```

## Configuration Details

### i3 Window Manager

**Location**: `i3/config`

Features:
- **No window borders or title bars** for maximum screen space
- **Vim-style navigation** (h/j/k/l for movement)
- **Multi-monitor support** via auto-display.sh
- **Application shortcuts** for quick focus switching
- **Workspace navigation** with bracket keys and Tab
- **Custom color scheme** matching Matrix theme

Auto-display script (`i3/auto-display.sh`):
- Detects external monitors automatically
- Configures dual external monitors (DVI-I-1-1 primary, DP-2 secondary)
- Falls back to laptop screen (eDP-1) with 200% scaling when unplugged
- Automatically restarts Polybar with correct monitor configuration

### Polybar

**Location**: `polybar/`

Three bars configured:
1. **main** - Top bar with i3 workspaces, filesystem, weather, date, system stats
2. **bottom** - Bottom bar with Spotify integration and network status
3. **topright** - Bar for secondary monitor

Modules:
- **i3**: Workspace indicator
- **filesystem**: Disk usage
- **weather**: Current weather via scripts
- **date**: Date and time
- **pulseaudio**: Volume control
- **memory**: RAM usage
- **cpu**: CPU usage
- **temperature**: System temperature
- **spotify**: Now playing (with scroll effect)
- **network**: Network status
- **bluetooth**: Bluetooth status

### Rofi

**Location**: `rofi/`

- Application launcher with Matrix theme
- Custom power menu with confirmation dialogs
- Hover-select enabled for mouse users
- Icons disabled for minimal aesthetic

Power menu options:
- Sleep (suspend)
- Lock (i3lock)
- Logout (exit i3)
- Reboot
- Shutdown

### Dunst

**Location**: `dunst/dunstrc`

Matrix-themed notification daemon:
- Green-on-black color scheme (#00FF41 primary)
- VCR OSD Mono font for authentic Matrix look
- Custom urgency levels with different colors
- Special rules for terminal, system, download notifications
- Click actions: left=close, middle=action, right=close all

### XFCE4 Terminal

**Location**: `xfce4/terminal/terminalrc`

- **Font**: JetBrains Mono Nerd Font 16
- **Color scheme**: Dark with yellow/gold highlights
- **No scrollbar**
- **Block cursor**
- **URL highlighting enabled**

### Zsh Configuration

**Location**: `.zshrc`

Environment setup:
- Spaceship theme
- FNM (Fast Node Manager) for Node.js
- pnpm and Bun paths configured
- Custom PATH additions

Plugins:
- git
- fasd
- docker & docker-compose
- zsh-autosuggestions
- zsh-syntax-highlighting

Extensive aliases for:
- **Node/npm**: `vs`, `ns`, `nb`, `pi`, `pd`, `ps`, `pb`
- **Git**: `g`, `gc`, `gs`, `gpp`, `wip`, `nah`, `glog`
- **Docker**: `dc` (docker compose)
- **Tmux**: `t`
- **Editors**: `ezsh`, `etmux`, `envim`
- **i3**: `i3r` (restart)
- **PHP/Laravel**: `art`, `migrate`, `tinker`, `mfs`
- **Cargo**: `cr`, `cb`
- **Spotify**: `spot` (Spotify desktop), `spt` (ncspot terminal client)
- **Heroku**: `h`, `hlogs`
- **System**: `btr` (restart bluetooth), `ip` (external IP)

### Tmux

**Location**: `.tmux.conf`

- **Prefix**: Ctrl+A (instead of Ctrl+B)
- **Vim-style pane navigation**: Ctrl+h/j/k/l
- **Split shortcuts**: | for horizontal, - for vertical
- **Window navigation**: Prefix+h/l for prev/next
- **Vi mode** for copy mode
- **Auto-renumber windows**
- **Plugins**: tpm, tmux-sensible, tmux-fingers, tmux-sessionist, tmux-resurrect

### Tridactyl (Firefox)

**Location**: `tridactyl/tridactylrc`

- **Theme**: Matrix
- **Smooth scrolling enabled**
- **Hints**: Letter-based (asdfgqwertzxcv) for easy left-hand access
- **Tab navigation**: J/K or gT/gt for prev/next
- **Tab management**: d closes tab and moves left, D just closes
- **Quickmarks**: g=GitHub, m=Gmail, y=YouTube, r=Reddit, h=HN, c=ChatGPT

## Keybindings

### i3 Window Manager

#### Essential

| Keybinding | Action |
|------------|--------|
| `Mod4` | Modifier key (Windows/Super key) |
| `Mod+Enter` | Open terminal (xfce4-terminal) |
| `Mod+Shift+q` | Kill focused window |
| `Mod+Shift+Return` | Rofi application launcher |
| `Mod+Shift+d` | Rofi run menu |

#### Window Navigation (Vim-style)

| Keybinding | Action |
|------------|--------|
| `Mod+h/j/k/l` | Focus window (left/down/up/right) |
| `Mod+Shift+h/j/k/l` | Move window (left/down/up/right) |
| `Mod+arrows` | Focus window (alternative) |
| `Mod+Shift+arrows` | Move window (alternative) |

#### Window Layout

| Keybinding | Action |
|------------|--------|
| `Mod+b` | Split horizontal |
| `Mod+v` | Split vertical |
| `Mod+f` | Toggle fullscreen |
| `Mod+w` | Tabbed layout |
| `Mod+e` | Toggle split layout |
| `Mod+Shift+space` | Toggle floating |
| `Mod+space` | Toggle focus tiling/floating |
| `Mod+r` | Resize mode (then h/j/k/l to resize) |

#### Workspace Navigation

| Keybinding | Action |
|------------|--------|
| `Mod+1-0` | Switch to workspace 1-10 |
| `Mod+Shift+1-0` | Move window to workspace 1-10 |
| `Mod+[` | Previous workspace |
| `Mod+]` | Next workspace |
| `Mod+Tab` | Toggle between current and previous workspace |
| `Mod+grave` | Jump to urgent window |

#### Application Shortcuts

| Keybinding | Action |
|------------|--------|
| `Mod+Shift+f` | Focus Firefox |
| `Mod+Shift+t` | Focus terminal |
| `Mod+Shift+v` | Focus VS Code |
| `Mod+Shift+m` | Focus Spotify |
| `Mod+Shift+a` | Focus Slack |

#### System

| Keybinding | Action |
|------------|--------|
| `Mod+Shift+e` | Power menu |
| `Mod+Shift+s` | Screenshot (Flameshot) |
| `Mod+Shift+p` | Refresh display configuration |
| `Mod+Shift+c` | Reload i3 config |
| `Mod+Shift+r` | Restart i3 |
| `Ctrl+Alt+z` | Spotify play/pause |
| `Ctrl+Alt+x` | Spotify next |
| `Ctrl+Alt+c` | Spotify previous |

### Tmux

| Keybinding | Action |
|------------|--------|
| `Ctrl+a` | Prefix (instead of Ctrl+b) |
| `Prefix+\|` | Split horizontal |
| `Prefix+-` | Split vertical |
| `Ctrl+h/j/k/l` | Navigate panes (vim-style) |
| `Prefix+h/l` | Navigate windows (prev/next) |
| `Prefix+r` | Reload tmux config |
| `Prefix+M` | Edit tmux config in vim |

### Tridactyl (Firefox)

| Keybinding | Action |
|------------|--------|
| `f` | Hint mode (links) |
| `J` / `gT` | Previous tab |
| `K` / `gt` | Next tab |
| `d` | Close tab (move left) |
| `D` | Close tab |
| `<<` / `>>` | Move tab left/right |
| `go<key>` | Open quickmark in current tab |
| `gn<key>` | Open quickmark in new tab |
| `yy` | Copy URL |
| `p` / `P` | Open clipboard URL (new/current tab) |

## Customization

### Changing the Color Scheme

The Matrix theme is defined in multiple files:

1. **Polybar colors**: `polybar/colors.ini`
2. **Dunst colors**: `dunst/dunstrc` (lines 75-94)
3. **i3 colors**: `i3/config` (lines 176-181)
4. **Rofi theme**: `~/.local/share/rofi/themes/matrix.rasi`
5. **Terminal colors**: `xfce4/terminal/terminalrc` (lines 32-42)

### Changing Monitors

Edit `i3/auto-display.sh` to match your monitor setup:
- Lines 9-11: External monitor configuration
- Line 27: Laptop display mode and scaling

Use `xrandr` to list available outputs and adjust accordingly.

### Adding/Removing Polybar Modules

Edit `polybar/config.ini`:
- Line 22: `modules-left`
- Line 23: `modules-center`
- Line 24: `modules-right`
- Line 35-37: Bottom bar modules

Module definitions are in `polybar/modules.ini`.

### Custom Aliases

Add your own aliases to `.zshrc` starting at line 29.

### Workspace Names

Currently using numeric workspaces (1-10). To add names, edit `i3/config` lines 93-102:
```i3
set $ws1 "1:web"
set $ws2 "2:code"
# etc.
```

## Troubleshooting

### Polybar Not Showing

```bash
# Check Polybar logs
tail -f /tmp/polybar-main.log
tail -f /tmp/polybar-bottom.log
tail -f /tmp/polybar-topright.log

# Manually restart Polybar
~/.config/polybar/launch.sh
```

### Fonts Not Displaying Correctly

Install required fonts:
```bash
# DejaVu Sans Mono
sudo apt install fonts-dejavu

# Font Awesome (for icons)
sudo apt install fonts-font-awesome

# JetBrains Mono Nerd Font
# Download from https://github.com/ryanoasis/nerd-fonts/releases
# Install manually or via font manager
```

### Display Configuration Issues

```bash
# List available outputs
xrandr

# Manually run auto-display script
~/.config/i3/auto-display.sh

# Use arandr for GUI configuration
arandr
```

### Spotify Integration Not Working

```bash
# Ensure playerctl is installed
sudo apt install playerctl

# Check if Spotify is detected
playerctl -l

# Make Spotify scripts executable
chmod +x ~/.config/polybar/scripts/*.sh
chmod +x ~/dotfiles/scripts/spotify/*.sh
```

### Rofi Theme Missing

The config references `/home/dan/.local/share/rofi/themes/matrix.rasi`. Either:
1. Create the theme file at that location
2. Use an existing theme: `rofi-theme-selector`
3. Update the path in `rofi/config.rasi` line 27

### Tmux Plugins Not Loading

```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Inside tmux, press: Prefix + I (capital i) to install plugins
# Or run:
~/.tmux/plugins/tpm/bin/install_plugins
```

### Zsh Plugins Not Working

```bash
# Ensure Oh-My-Zsh is installed
test -d ~/.oh-my-zsh && echo "Installed" || echo "Not installed"

# Install missing plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Reload Zsh
source ~/.zshrc
```

### Weather Not Showing in Polybar

Check the weather script:
```bash
# Test the script
~/.config/polybar/scripts/weather.sh

# Make sure it's executable
chmod +x ~/.config/polybar/scripts/weather.sh

# Check if it needs API keys or network access
```

## Development Tools Included

The `.zshrc` includes paths and configurations for:

- **Node.js**: FNM (Fast Node Manager)
- **Package Managers**: npm, pnpm, yarn, bun
- **Runtimes**: Bun, Node.js (via FNM)
- **Languages**: Rust (cargo), PHP (composer, artisan)
- **DevOps**: Docker, Docker Compose, Heroku CLI
- **Version Control**: Git with LazyGit
- **Editors**: Vim, Neovim
- **Utilities**: bat (better cat), ripgrep, fzf

## Credits

- **i3**: [i3wm.org](https://i3wm.org/)
- **Polybar**: [github.com/polybar/polybar](https://github.com/polybar/polybar)
- **Oh-My-Zsh**: [ohmyz.sh](https://ohmyz.sh/)
- **Spaceship Theme**: [spaceship-prompt.sh](https://spaceship-prompt.sh/)
- **Rofi**: [github.com/davatorium/rofi](https://github.com/davatorium/rofi)
- **Dunst**: [dunst-project.org](https://dunst-project.org/)
- **Tridactyl**: [github.com/tridactyl/tridactyl](https://github.com/tridactyl/tridactyl)
- **Matrix aesthetic inspiration**: The Matrix (1999)

## License

Feel free to use, modify, and distribute these configurations as you see fit.

---

**Enjoy your new Matrix-themed workspace!**

For issues or questions, please open an issue in this repository.
