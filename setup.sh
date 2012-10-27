#! /bin/bash

if [ -z "$(which ruby)" ]; then
  pacman -S ruby
fi
curl "https://raw.github.com/asayers/provision/master/provision.rb" | ruby
