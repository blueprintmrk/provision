#! /usr/bin/env ruby

class Package
  def initialize name
    @name = name
  end
  def to_s
    @name
  end
  def installed?
    `pacman -Q #{@name} 2>&1`.match(/^#{@name} [0-9a-z._-]*$/)
  end
  def install!
    `pacman -S --noconfirm #{@name}`
  end
end

class User
  attr_accessor :name, :options
  def initialize name, options
    @name = name
    @options = options
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
    print "Passphrase for #{@name}: "
    passphrase = gets
    `sudo -u #{@name} ssh-keygen -t rsa -C #{EMAIL} -f /home/#{@name}/.ssh/id_rsa -N #{passphrase}`
  end
  def has_gh_access?
    `sudo -u #{@name} ssh -o StrictHostKeyChecking="no" -T git@github.com 2>&1`.strip.split("\n").last.match(/^Hi #{GH_USER}!/)
  end
  def clone_from_gh!
    `su - #{@name} -c "cd && git clone git@github.com:#{GH_USER}/#{@options[:gh_repo]}.git"`
  end
  def create_db_user!
    `su - postgres -c "createuser -s #{@name}"`
  end
end

# Set constants
HOSTNAME  = "vanaheimr"
EMAIL     = "alex.sayers@gmail.com"
GH_USER   = "asayers"
PACKAGES  = ["base-devel", "zsh", "ruby", "git", "htop", "tmux", "nginx", "postgresql", "redis"]
USERS     = [User.new("scientia", {db_user: true, gh_repo: "scientia"})]

PACKAGES.map! { |p| Package.new(p) }


#General setup
puts "Setting hostname #{HOSTNAME}..."
`echo "#{HOSTNAME}" > /etc/hostname`
puts "Setting locale en_US.UTF-8"
`echo 'LANG="en_US.UTF-8"' > /etc/locale.conf`
`echo "KEYMAP=uk\nFONT=\nFONT_MAP=" > /etc/vconsole.conf`
`echo "en_US.UTF-8 UTF-8" > /etc/locale.gen`
`locale-gen`
puts "Setting terminfo for urxvt"
`curl "https://raw.github.com/asayers/provision/master/rxvt-unicode-256color" > /usr/share/terminfo/r/rxvt-unicode-256color`
# TODO: Edit sudoers to allow wheel
# TODO: Change default shell to zsh

# Install packages
print "Upgrading installed packages..."
`pacman -Syu --noconfirm`
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

# Nginx setup
puts "Setting up nginx..."
unless File.exists? "/etc/nginx/sites-enabled"
  `mkdir /etc/nginx/sites-available`
  `mkdir /etc/nginx/sites-enabled`
  `curl "https://raw.github.com/asayers/provision/master/nginx.conf" > /etc/nginx/nginx.conf`
  `curl "https://raw.github.com/asayers/provision/master/nginx_default.conf" > /etc/nginx/sites-available/default`
end
`systemctl start nginx`

# Postgres setup
puts "Setting up postgres..."
`chown -R postgres /var/lib/postgres/`
unless File.exist? "/var/lib/postgres/data"
  `su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"`
end
unless File.exist? "/run/postgresql"
  `mkdir /run/postgresql`
  `chown postgres /run/postgresql/`
end
`systemctl start postgresql`

# Redis setup
puts "Setting up redis..."
`systemctl start redis`

# Enable services at boot
puts "Enabling serives at boot... "
`systemctl enable nginx`
`systemctl enable postgresql`
`systemctl enable redis`

# Create users
USERS.each do |u|
  print "Checking for user #{u}... "
  unless u.exists?
    puts "does not exist! Creating..."
    u.create!
    u.generate_ssh_key!
    u.create_db_user! if u.options[:db_user]
  else
    puts "exists!"
  end
#  if u.options[:gh_repo]
#    puts "Cloning into repo #{u.options[:gh_repo]}..."
#    u.clone_from_gh! unless File.exist? "/home/#{u.name}/#{u.options[:gh_repo]}"
#  end

  # TODO: Add to wheel group
  # TODO: Add password
  # TODO: Add database-user password
  # TODO: git config --global user.email "alex.sayers@gmail.com"
  # TODO: git config --global user.name "Alex Sayers"
end