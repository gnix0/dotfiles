export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
	colored-man-pages
)
source $ZSH/oh-my-zsh.sh
alias dev="~/.local/bin/tmux-sessionizer"
export EDITOR="emacs"
eval $(thefuck --alias)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export PATH="$HOME/.cargo/bin:$PATH"
source <(ng completion script)
eval "$(direnv hook zsh)"
export JAVA_HOME=/usr/lib/jvm/default
export PATH=$PATH:$HOME/go/bin
# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
