# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH;

export ZSH="/home/dan/.oh-my-zsh"
export PATH="${PATH}:${HOME}/.local/bin/"

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

# Fedora
alias btr="sudo systemctl restart bluetooth.service"

# Rust
alias cr="cargo run"
alias cb="cargo build"

# Docker
alias dc="docker compose"

alias q="yarn server"
alias lg="lazygit"
alias g="git"
alias gc="git checkout"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias wip="git add . && git commit -m 'wip'"
alias nah="git reset --hard && git clean -df"
alias p="vendor/bin/phpunit"
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
alias ....="cd ../../../"
alias .....="cd ../../../../"

alias finder='open -a 'Finder' .'
alias ip="curl icanhazip.com"
alias rcli="redis-cli"

alias cat="bat"

alias i3r="i3-msg restart"
alias ezsh="vim ~/.zshrc"
alias ebash="vim ~/.bash_profile"
alias ephpcs="vim ~/.vscode/.php_cs"
alias etmux="vim ~/.tmux.conf"
alias envim="nvim ~/.config/nvim/init.vim"
alias evim="vim ~/.vimrc"
alias exr="vim ~/.Xresources"

alias nrbg="npm run build:graphql"


plugins=(git fasd zsh-autosuggestions zsh-syntax-highlighting docker docker-compose)

source $ZSH/oh-my-zsh.sh

export PNPM_HOME="/home/dan/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
