#! /bin/bash

if [ -z "$(which ruby)" ]; then
  haveged -w 1024
  pacman-key --init
  pkill haveged
  pacman-key --populate archlinux
  pacman -S ruby
fi
curl "https://raw.github.com/asayers/provision/master/provision.rb" | ruby
