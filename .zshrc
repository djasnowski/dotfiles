# ===== PATH & basics =====
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.config/rofi/scripts:$PATH"
export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig/"

# ===== oh-my-zsh =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"

# ===== Editor & configs =====
export EDITOR="vim"
export MYVIMRC="$HOME/.vimrc"
export MYNVIMRC="$HOME/.config/nvim/init.vim"
export TMUXCONF="$HOME/.tmux.conf"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# ===== History =====
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.cache/zshhistory"
setopt appendhistory

# ===== FNM (must come BEFORE oh-my-zsh) =====
export FNM_DIR="$HOME/.local/share/fnm"
export PATH="$FNM_DIR:$PATH"
eval "$(fnm env --use-on-cd)"


# ===== Aliases =====
alias vs="npm run serve"
alias ns="npm start"
alias nb="npm run build"
alias nrw="npm run watch"
alias qq="npm run ndb"
alias p="pnpm"
alias pi="p install"
alias pd="p dev"
alias ps="p run start"
alias pb="p build"

alias btr="sudo systemctl restart bluetooth.service"
alias 1p="op signin"

alias cr="cargo run"
alias cb="cargo build"

alias t="tmux"

alias b="bun"
alias bd="bun dev"
alias bb="bun build"

alias h="heroku"
alias hlogs="heroku addons:open logdna"

alias dc="docker compose"

alias spot="flatpak run com.spotify.Client"
alias spt="flatpak run io.github.hrkfdn.ncspot"
alias q="yarn server"
alias lg="lazygit"
alias g="git"
alias gc="git checkout"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias wip="git add . && git commit -m 'wip'"
alias nah="git reset --hard && git clean -df"
alias pu="vendor/bin/phpunit"
alias pf="vendor/bin/phpunit --filter "
alias art="php artisan"
alias gtd="git checkout dev"
alias gtm="git checkout master"
alias gfp="git fetch && git pull"
alias gs="git status"
alias gpp="git push"
alias migrate="php artisan migrate"
alias aserve="php artisan serve"
alias tinker="php artisan tinker"
alias mfs="php artisan migrate:fresh --seed"
alias mf="php artisan migrate:fresh"
alias vd="ls -la"
alias cls="clear"
alias phpserv="php -S localhost:7777 -t ."

alias ..="cd ../"
alias ...="cd ../../"

# macOS-only; harmless on Linux if 'open' exists via xdg-utils shim, else remove it
alias finder='open -a "Finder" .'

alias ip="curl icanhazip.com"
alias rcli="redis-cli"

# On Ubuntu 'bat' is usually 'batcat'; switch if 'bat' isn't found
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias cat="batcat"
else
  alias cat="bat"
fi

alias i3r="i3-msg restart"
alias ezsh="nvim ~/.zshrc"
alias ebash="nvim ~/.bash_profile"
alias ephpcs="nvim ~/.vscode/.php_cs"
alias etmux="nvim ~/.tmux.conf"
alias envim="nvim ~/.config/nvim/init.vim"
alias evim="nvim ~/.vimrc"
alias exr="nvim ~/.Xresources"
alias eqt="nvim ~/.config/qutebrowser/config.py"
alias nrbg="npm run build:graphql"

# ===== Plugins (syntax-highlighting MUST be last) =====
plugins=(
  git
  fasd
  docker
  docker-compose
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ===== pnpm =====
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ===== Bun =====
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Optional: extra functions path
fpath=($fpath "$HOME/.zfunctions")
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# fnm
FNM_PATH="/home/dan/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
