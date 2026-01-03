#!/bin/bash

# Dotfiles installation script
# Creates symlinks from ~/.config to ~/dotfiles

set -e

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$CONFIG_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
info "Backup directory: $BACKUP_DIR"

# Function to create symlink with backup
link_config() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        warn "Source does not exist: $src"
        return
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Backup existing file/directory if it exists and is not a symlink to our dotfiles
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ]; then
            local current_target=$(readlink "$dest")
            if [ "$current_target" = "$src" ]; then
                info "Already linked: $dest"
                return
            fi
        fi
        local backup_path="$BACKUP_DIR/$(basename "$dest")"
        warn "Backing up existing: $dest -> $backup_path"
        mv "$dest" "$backup_path"
    fi

    ln -sf "$src" "$dest"
    info "Linked: $dest -> $src"
}

echo ""
echo "=================================="
echo "  Dotfiles Installation Script"
echo "=================================="
echo ""

# Config directories
info "Linking config directories..."
link_config "$DOTFILES_DIR/i3" "$CONFIG_DIR/i3"
link_config "$DOTFILES_DIR/polybar" "$CONFIG_DIR/polybar"
link_config "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi"
link_config "$DOTFILES_DIR/dunst" "$CONFIG_DIR/dunst"
link_config "$DOTFILES_DIR/xfce4" "$CONFIG_DIR/xfce4"
link_config "$DOTFILES_DIR/tridactyl" "$CONFIG_DIR/tridactyl"
link_config "$DOTFILES_DIR/scripts" "$CONFIG_DIR/scripts"
link_config "$DOTFILES_DIR/zscroll" "$CONFIG_DIR/zscroll"

# Local bin (zscroll for polybar spotify)
info "Linking local bin scripts..."
mkdir -p "$HOME/.local/bin"
link_config "$CONFIG_DIR/zscroll/zscroll" "$HOME/.local/bin/zscroll"

# Home directory dotfiles
info "Linking home directory dotfiles..."
link_config "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Make scripts executable
info "Making scripts executable..."
find "$DOTFILES_DIR" -name "*.sh" -exec chmod +x {} \;

echo ""
info "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Reload i3: Mod+Shift+r"
echo "  2. Reload tmux: tmux source ~/.tmux.conf"
echo "  3. Reload zsh: source ~/.zshrc"
echo "  4. Reload Tridactyl: :source in Firefox"
echo ""

# Check if backup directory is empty and remove if so
if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    rmdir "$BACKUP_DIR"
    info "No backups needed, removed empty backup directory"
else
    warn "Backups saved to: $BACKUP_DIR"
fi
