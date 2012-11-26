#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto -h'

export PS1="\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;34m\]\h\[\e[0m\]:\[\e[0;31m\]\W\[\e[0m\]\$ "
export PATH=$PATH:$HOME/.gem/ruby/1.9.1/bin
export EDITOR="/usr/bin/vim"
