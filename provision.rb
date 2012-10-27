#! /usr/bin/env ruby

USERS=["scientia"]
PACKAGES=["zsh", "ruby", "git", "nginx", "postgresql", "redis"]
EMAIL="alex.sayers@gmail.com"

print "Checking pacman keyring is populated... "
if `pacman-key -l`.empty?
  puts "it is not! Populating..."
  `pacman-key --init`
  `pacman-key --populate archlinux`
else
  puts "it is!"
end
puts "Upgrading installed packages..."
`pacman -Syu`
packages.each do |p|
  print "Checking #{p}... "
  if `pacman -Q git`.match(/^#{p} [0-9.-]*$/).nil?
    puts "not installed! Installing..."
    `pacman -S #{p}`
  else
    puts "already installed!"
  end
end
users.each do |u|
  print "Checking #{u}... "
  if `cat /etc/passwd`.match(/^#{u}:/).nil?
    puts "does not exist! Creating..."
    `useradd -m #{u}`
    `sudo -u #{u} ssh-keygen -t rsa -C #{email}`
  else
    puts "exists!"
  end
end
# git clone git@github.com:asayers/$USER.git ~$USER
