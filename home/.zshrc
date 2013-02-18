#
# ~/.zshrc
#

# If the terminal is interactive and not in a tmux session, connect to one
if [[ $- == *i* && -z "$TMUX" ]]; then
     # Look for unattached sessions
     SESSION=$(tmux ls | sed -e '/(attached)$/d' -e 's/:.*$//' | head -n 1)
     if [ -z $SESSION ]; then
          # None found!
          exec tmux
     else
          # Got one!
          exec tmux attach -t $SESSION
     fi
fi

# Aliases
alias ls='ls --color=auto -h'

# Variables
export PROMPT='%F{green}%n%F{default}@%F{blue}%m%F{default}:%F{red}%~%F{default}%(?/$/!) '
export EDITOR="/usr/bin/vim"
export RAILS_ENV="production"
export RBENV_ROOT="${HOME}/.rbenv"
if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi
