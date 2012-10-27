#! /bin/bash

echo "Installing ruby..."
pacman -S ruby
echo "Provisioning server..."
wget https://raw.github.com/asayers/provision/master/provision.rb | ruby
