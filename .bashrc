#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias dev="$HOME/.local/bin/tmux-sessionizer"

export EDITOR="emacs"
export JAVA_HOME="/usr/lib/jvm/default"

export PATH="$HOME/.cargo/bin:$HOME/go/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Angular CLI completion
command -v ng >/dev/null 2>&1 && source <(ng completion script)

# direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"

PS1='[\u@\h \W]\$ '
