#!/bin/bash
# <UDF name="hostname" label="Host name" example="Desired host name of your Linode" />
# <UDF name="userpass" label="Unprivileged user password" />
# <UDF name="gitname" label="Full name for git" />
# <UDF name="gitemail" label="Email for git" />

# Setting hostname
echo $HOSTNAME > /etc/hostname

# Setting locale
echo -e "en_GB.UTF-8 UTF-8\nen_US.UTF-8 UTF-8" > /etc/locale.gen
echo 'LANG="en_GB.UTF-8"' > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
locale-gen

# Setting timezone to London
#ln -s /usr/share/zoneinfo/Europe/London /etc/localtime   # Already set to UTC
#hwclock --systohc --utc

# Initializing pacman
haveged -w 1024
pacman-key --init
pkill haveged
curl "https://raw.github.com/asayers/provision/master/pacman.conf" > ~/pacman.conf
#pacman-key --populate archlinux

# Upgrading system
pacman -Syu --noconfirm --config ~/pacman.conf
pacman -Syu --noconfirm --config ~/pacman.conf
pacman -S --noconfirm --config ~/pacman.conf base-devel htop tmux vim git nginx postgresql redis

# Adding urxvt terminfo
curl "https://raw.github.com/asayers/provision/master/rxvt-unicode-256color" > /usr/share/terminfo/r/rxvt-unicode-256color

# Configuring user: root
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Configuring user: deployer
useradd -m -g users -G wheel -s /bin/bash deployer
passwd deployer <<EOF
$USERPASS
$USERPASS
EOF
chown -R deployer:users /home/deployer
chmod a+rx /home/deployer
su - deployer -c "ssh-keygen -t rsa -f ~/.ssh/id_rsa -N $USERPASS"
su - deployer -c 'curl "https://raw.github.com/asayers/provision/master/id_rsa.pub" > ~/.ssh/authorized_keys'
su - deployer -c 'curl "https://raw.github.com/asayers/provision/master/bashrc" > ~/.bashrc'

# Setting up git
su - deployer -c "git config --global user.name '$GITNAME'"
su - deployer -c "git config --global user.email '$GITEMAIL'"

# Setting up ruby
su deployer
cd ~
curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
rbenv install 1.9.3-p194
rbenv global 1.9.3-p194
rbenv bootstrap
rbenv rehash
exit

# Setting up nginx
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
curl "https://raw.github.com/asayers/provision/master/nginx.conf" > /etc/nginx/nginx.conf
curl "https://raw.github.com/asayers/provision/master/nginx_default.conf" > /etc/nginx/sites-available/default
systemctl enable nginx
systemctl start nginx

# Setting up postgres
chown -R postgres /var/lib/postgres/
su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"
su - postgres -c "createuser -d deployer"
mkdir /run/postgresql
chown postgres /run/postgresql/
systemctl enable postgresql
systemctl start postgresql

# Setting up redis
systemctl enable redis
systemctl start redis

# Maybe add a password for the deployer postgres user? Use -P <<EOF etc.
