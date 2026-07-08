export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
	history
	colored-man-pages
	zsh-autosuggestions
	zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh
alias dev="~/.local/bin/tmux-sessionizer"
export EDITR="vim"
eval $(thefuck --alias)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
source <(ng completion script)
eval "$(direnv hook zsh)"
export JAVA_HOME=/usr/lib/jvm/default
