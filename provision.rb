#! /usr/bin/env ruby

USERS=["scientia"]
PACKAGES=["zsh", "ruby", "git", "nginx", "postgresql", "redis"]
EMAIL="alex.sayers@gmail.com"

class Pacman
  def self.populated?
    !`pacman-key -l`.empty?
  end
  def self.populate!
  `pacman-key --init`
  `pacman-key --populate archlinux`
  end
end

class Package
  def initialize name
    @name = name
  end
  def to_s
    @name
  end
  def installed?
    return !`pacman -Q #{@name}`.match(/^#{@name} [0-9a-z.-_]*$/).nil?
  end
  def install!
    `pacman -S --noconfirm #{@name}`
  end
end
PACKAGES.map! { |p| Package.new(p) }

class User
  def initialize name
    @name = name
  end
  def to_s
    name
  end
  def exists?
    return !`cat /etc/passwd`.match(/^#{u}:/).nil?
  end
  def create!
    `useradd -m #{u}`
  end
  def generate_ssh_key!
    `sudo -u #{u} ssh-keygen -t rsa -C #{EMAIL}`
  end
end
USERS.map! { |u| User.new(u) }


print "Checking pacman keyring is populated... "
unless Pacman.populated?
  puts "it is not! Populating..."
  Pacman.populate!
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
  unless u.exists?
    puts "does not exist! Creating..."
    u.create!
    u.generate_ssh_key!
  else
    puts "exists!"
  end
end
# git clone git@github.com:asayers/$USER.git ~$USER
