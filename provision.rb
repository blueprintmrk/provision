#! /usr/bin/env ruby

EMAIL="alex.sayers@gmail.com"
GH_USER="asayers"
PACKAGES=["zsh", "ruby", "git", "nginx", "postgresql", "redis"]
USERS=["scientia"]
GH_PROJECTS={"scientia"=>"scientia"}

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
    `pacman -Q #{@name}`.match(/^#{@name} [0-9a-z._-]*$/)
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
    @name
  end
  def exists?
    `cat /etc/passwd`.match(/^#{@name}:/)
  end
  def create!
    `useradd -m #{@name}`
  end
  def generate_ssh_key!
    `sudo -u #{@name} ssh-keygen -t rsa -C #{EMAIL}`
  end
  def has_github_access?
    # This doesn't work, because `` stops returning stdout once input has been requested. Use Popen instead.
    #`sudo -u #{@name} ssh -o StrictHostKeyChecking="no" -T git@github.com`.strip.split("\n").last.match(/^Hi #{GH_USER}!/)
  end
end
USERS.map! { |u| User.new(u) }
GH_PROJECTS.each{ |p,u| GH_PROJECTS[p] = User.new(u) }


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

GH_PROJECTS.each do |project, user|
  puts "Cloning #{project}..."
  `sudo -u #{user} git clone git@github.com:#{GH_USER}/#{project}.git ~#{user}/`
end
