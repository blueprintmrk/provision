#! /bin/bash

HOSTNAME=vanaheimr
EMAIL=alex.sayers@gmail.com

echo "Setting hostname to $HOSTNAME"
echo $HOSTNAME > /etc/hostname

echo "Setting locale to en_GB.UTF-8"
echo "en_GB.UTF-8 UTF-8\nen_US.UTF-8 UTF-8" > /etc/locale.gen
echo 'LANG="en_GB.UTF-8"' > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
locale-gen

echo "Setting timezone to London"
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc

echo "Initializing pacman"
haveged -w 1024
pacman-key --init
pkill haveged
pacman-key --populate archlinux

echo "Adding urxvt terminfo"
curl "https://raw.github.com/asayers/provision/master/rxvt-unicode-256color" > /usr/share/terminfo/r/rxvt-unicode-256color

echo "Configuring user: root"
passwd
# Edit sudoers to allow wheel

echo "Configuring user: deployer"
useradd -m -g users -G wheel -s /bin/bash deployer
passwd deployer
su - deployer -c "ssh-keygen -t rsa -C $EMAIL -f ~/.ssh/id_rsa -N"
su - deployer -c 'curl "https://raw.github.com/asayers/provision/master/id_rsa.pub" > ~/.ssh/authorized_keys'

echo "Upgrading system"
pacman -Syu --noconfirm
pacman -S --noconfirm base-devel ruby git htop tmux nginx postgresql redis

echo "Setting up git"
su - deployer -c "git config --global user.name 'Alex Sayers'"
su - deployer -c "git config --global user.email '$EMAIL'"

echo "Setting up nginx"
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
curl "https://raw.github.com/asayers/provision/master/nginx.conf" > /etc/nginx/nginx.conf
curl "https://raw.github.com/asayers/provision/master/nginx_default.conf" > /etc/nginx/sites-available/default
systemctl enable nginx
systemctl start nginx

echo "Setting up postgres"
chown -R postgres /var/lib/postgres/
su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"
su - postgres -c "createuser -s deployer"
mkdir /run/postgresql
chown postgres /run/postgresql/
systemctl enable postgresql
systemctl start postgresql

echo "Setting up redis"
systemctl enable redis
systemctl start redis

echo "Remember to add wheel to sudoers"
echo "Maybe add a password for the deployer postgres user?"
echo "Remember to add deployer's key to github:"
echo ~deployer/.ssh/id_rsa.pub
