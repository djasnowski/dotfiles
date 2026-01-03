#!/bin/bash

# Dotfiles installation script
# Usage:
#   ./install.sh           - Only create symlinks
#   ./install.sh --deps    - Install apt packages + symlinks
#   ./install.sh --all     - Full install (packages, zsh plugins, symlinks)

set -e

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$CONFIG_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
section() { echo -e "\n${BLUE}==>${NC} $1\n"; }

# Parse arguments
INSTALL_DEPS=false
INSTALL_ALL=false

for arg in "$@"; do
    case $arg in
        --deps|-d)
            INSTALL_DEPS=true
            ;;
        --all|-a)
            INSTALL_DEPS=true
            INSTALL_ALL=true
            ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  (none)       Only create symlinks"
            echo "  --deps, -d   Install apt packages + create symlinks"
            echo "  --all, -a    Full install (packages, zsh plugins, tpm, symlinks)"
            echo "  --help, -h   Show this help message"
            exit 0
            ;;
    esac
done

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

echo ""
echo "=================================="
echo "  Dotfiles Installation Script"
echo "=================================="

# Install apt packages
install_packages() {
    section "Installing apt packages"

    sudo apt update

    info "Installing core packages..."
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

    info "Installing fonts..."
    sudo apt install -y \
        fonts-dejavu \
        fonts-font-awesome

    info "Installing shell and terminal tools..."
    sudo apt install -y \
        zsh \
        tmux \
        git \
        curl \
        wget

    info "Installing development tools..."
    sudo apt install -y \
        build-essential \
        ripgrep \
        bat \
        lazygit || warn "Some dev tools may not be available in apt"

    info "Installing display tools..."
    sudo apt install -y \
        x11-xserver-utils \
        arandr || true
}

# Install additional dependencies (oh-my-zsh, plugins, etc.)
install_extras() {
    section "Installing additional dependencies"

    # Oh-My-Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        info "Oh-My-Zsh already installed"
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Spaceship theme
    if [ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
        info "Installing Spaceship theme..."
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
        ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    else
        info "Spaceship theme already installed"
    fi

    # Zsh plugins
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        info "zsh-autosuggestions already installed"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        info "zsh-syntax-highlighting already installed"
    fi

    # Tmux Plugin Manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    else
        info "TPM already installed"
    fi

    # rofi-bluetooth
    if [ ! -d "$CONFIG_DIR/rofi-bluetooth" ]; then
        info "Installing rofi-bluetooth..."
        git clone https://github.com/nickclyde/rofi-bluetooth.git "$CONFIG_DIR/rofi-bluetooth"
    else
        info "rofi-bluetooth already installed"
    fi

    # FNM (Fast Node Manager)
    if [ ! -d "$HOME/.local/share/fnm" ]; then
        info "Installing FNM..."
        curl -fsSL https://fnm.vercel.app/install | bash
    else
        info "FNM already installed"
    fi

    # Bun
    if [ ! -d "$HOME/.bun" ]; then
        info "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
    else
        info "Bun already installed"
    fi

    # pnpm
    if ! command -v pnpm &> /dev/null; then
        info "Installing pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    else
        info "pnpm already installed"
    fi
}

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

# Create symlinks
create_symlinks() {
    section "Creating symlinks"

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

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

    # Rofi themes
    info "Linking rofi themes..."
    mkdir -p "$HOME/.local/share/rofi/themes"
    link_config "$DOTFILES_DIR/rofi/matrix.rasi" "$HOME/.local/share/rofi/themes/matrix.rasi"

    # Wallpaper
    info "Setting up wallpaper..."
    mkdir -p "$HOME/Pictures"
    if [ -f "$DOTFILES_DIR/wallpapers/matrix-wallpaper.png" ]; then
        cp "$DOTFILES_DIR/wallpapers/matrix-wallpaper.png" "$HOME/Pictures/"
        info "Wallpaper copied to ~/Pictures/"
    elif [ ! -f "$HOME/Pictures/matrix-wallpaper.png" ]; then
        info "Downloading wallpaper..."
        wget -q -O "$HOME/Pictures/matrix-wallpaper.png" \
            "https://raw.githubusercontent.com/djasnowski/dotfiles/master/wallpapers/matrix-wallpaper.png"
    else
        info "Wallpaper already exists"
    fi

    # Make scripts executable
    info "Making scripts executable..."
    find "$DOTFILES_DIR" -name "*.sh" -exec chmod +x {} \;
    chmod +x "$DOTFILES_DIR/zscroll/zscroll" 2>/dev/null || true

    # Check if backup directory is empty and remove if so
    if [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    else
        warn "Backups saved to: $BACKUP_DIR"
    fi
}

# Post-install setup
post_install() {
    section "Post-install setup"

    # Set zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
    else
        info "Zsh already default shell"
    fi

    # Install tmux plugins
    if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
        info "Installing tmux plugins..."
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    fi

    # Reload i3 if running
    if pgrep -x "i3" > /dev/null; then
        info "Reloading i3..."
        i3-msg reload > /dev/null 2>&1 || true
    fi

    # Reload tmux if running
    if pgrep -x "tmux" > /dev/null; then
        info "Reloading tmux config..."
        tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
    fi
}

# Run installation
if [ "$INSTALL_DEPS" = true ]; then
    install_packages
fi

if [ "$INSTALL_ALL" = true ]; then
    install_extras
fi

create_symlinks

if [ "$INSTALL_ALL" = true ]; then
    post_install
fi

echo ""
info "Installation complete!"
echo ""
echo "Note: Reload Tridactyl in Firefox with :source"
echo ""
