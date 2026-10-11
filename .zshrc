export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

alias reboot="systemctl reboot"
alias poweroff="systemctl poweroff"
alias vim="nvim"

export EDITOR="nvim"
export PATH="$HOME/.cargo/bin:$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/usr/sbin:$PATH"

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"

unalias gf 2>/dev/null

alias get_idf='. $HOME/esp/esp-idf/export.sh'

alias noise='ffplay -f lavfi "anoisesrc=c=pink:r=48000"'
export PATH="$HOME/Downloads/kof-0.5.0-beta-linux-x86_64/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/home/gnix/.local/bin:$PATH"
