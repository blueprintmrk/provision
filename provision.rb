#! /usr/bin/env ruby


USERS=["scientia"]
PACKAGES=["zsh", "ruby", "git", "nginx", "postgresql", "redis"]
EMAIL="alex.sayers@gmail.com"


class Package
  def initialize name
    @name = name
  end
  def to_s
    @name
  end
  def installed?
    !`pacman -Q #{@name}`.match(/^#{@name} [0-9a-z.-_]*$/).nil?
  end
  def install!
    `pacman -S #{@name}`
  end
end
PACKAGES.map! { |p| Package.new(p) }


print "Checking pacman keyring is populated... "
if `pacman-key -l`.empty?
  puts "it is not! Populating..."
  `pacman-key --init`
  `pacman-key --populate archlinux`
else
  puts "it is!"
end

print "Upgrading installed packages..."
`pacman -Syu`
puts "done!"

PACKAGES.each do |p|
  print "Checking #{p}... "
  unless p.installed?
    puts "not installed! Installing..."
    p.install!
  else
    puts "already installed!"
  end
end

USERS.each do |u|
  print "Checking for #{u}... "
  if `cat /etc/passwd`.match(/^#{u}:/).nil?
    puts "does not exist! Creating..."
    `useradd -m #{u}`
    `sudo -u #{u} ssh-keygen -t rsa -C #{EMAIL}`
  else
    puts "exists!"
  end
end
# git clone git@github.com:asayers/$USER.git ~$USER

