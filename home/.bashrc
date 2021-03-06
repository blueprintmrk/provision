#
# ~/.bashrc
#

alias ls='ls --color=auto -h'

export PS1="\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;34m\]\h\[\e[0m\]:\[\e[0;31m\]\W\[\e[0m\]\$ "
export EDITOR="/usr/bin/vim"
export RBENV_ROOT="${HOME}/.rbenv"
export RAILS_ENV="production"

if [ -d "${RBENV_ROOT}" ]; then
  export PATH="${RBENV_ROOT}/bin:${PATH}"
  eval "$(rbenv init -)"
fi

