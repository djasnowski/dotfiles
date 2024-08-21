# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH;

export ZSH="/home/dan/.oh-my-zsh"
export PATH="${PATH}:${HOME}/.local/bin/"
export PATH=$HOME/.config/rofi/scripts:$PATH

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig/

ZSH_THEME="spaceship"

# export VIMINIT='source $MYVIMRC'
export EDITOR='vim'
export MYVIMRC='~/.vimrc'
export MYNVIMRC='~/.config/nvim/init.vim'
export TMUXCONF='~/.tmux.conf'

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zshhistory
setopt appendhistory

# NPM Scripts
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

# Fedora
alias btr="sudo systemctl restart bluetooth.service"
alias 1p="op signin"

# Rust
alias cr="cargo run"
alias cb="cargo build"

# Tmux
alias t="tmux"

# bun
alias b="bun"
alias bd="bun dev"
alias bb="bun build"

# Heroku
alias h="heroku"
alias hlogs="heroku addons:open logdna"

# Docker
alias dc="docker compose"

alias spot="flatpak run com.spotify.Client"
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
alias gc="git checkout"
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

alias finder='open -a 'Finder' .'
alias ip="curl icanhazip.com"
alias rcli="redis-cli"

alias cat="bat"

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


plugins=(git fasd zsh-autosuggestions zsh-syntax-highlighting docker docker-compose)

source $ZSH/oh-my-zsh.sh

export PNPM_HOME="/home/dan/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# fnm
export PATH=/home/dan/.fnm:$PATH
eval "`fnm env`"

# bun completions
[ -s "/home/dan/.bun/_bun" ] && source "/home/dan/.bun/_bun"

eval "$(op completion zsh)"; compdef _op op

# Bun
export BUN_INSTALL="/home/dan/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
fpath=($fpath "/home/dan/.zfunctions")

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
prompt spaceship

# pnpm
export PNPM_HOME="/home/dan/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
