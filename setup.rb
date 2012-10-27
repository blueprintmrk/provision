#! /usr/bin/env ruby

users=["scientia"]
packages=["zsh", "ruby", "git", "nginx", "postgresql", "redis"]
email="alex.sayers@gmail.com"

puts "Checking pacman keyring is populated..."
if `pacman-key -l`.empty?
  `pacman-key --init`
  `pacman-key --populate archlinux`
end
puts "Upgrading packages..."
`pacman -Syu`
packages.each do |p|
  if `pacman -Q git`.match(/^#{p} [0-9.-]*$/).nil?
    puts "Installing #{p}..."
    `pacman -S #{p}`
    `sudo -u $USER ssh-keygen -t rsa -C #{email}`
  else
    puts "#{p} already installed"
  end
end
users.each do |u|
  if `cat /etc/passwd`.match(/^#{u}:/).nil?
    `useradd -m #{u}`
  else
    puts "User #{u} exists"
  end
end
# git clone git@github.com:asayers/$USER.git ~$USER
