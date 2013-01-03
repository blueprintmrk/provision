#! /bin/bash
# 
# This script will set up a fresh install of Arch Linux with ruby and nginx, as
# well as the usual necessities. It must be run interactively.

URL="https://raw.github.com/asayers/provision/master"
HOSTNAME="vanaheimr"
NAME="Alex Sayers"
EMAIL="alex.sayers@gmail.com"

echo "Setting hostname to $HOSTNAME"; read
echo $HOSTNAME > /etc/hostname

echo "Setting locale to en_GB.UTF-8"; read
echo -e "en_GB.UTF-8 UTF-8\nen_US.UTF-8 UTF-8" > /etc/locale.gen
echo 'LANG="en_GB.UTF-8"' > /etc/locale.conf
echo "KEYMAP=uk" > /etc/vconsole.conf
locale-gen

echo "Setting timezone to London"; read
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc

echo "Initializing pacman"; read
haveged -w 1024
pacman-key --init
pkill haveged
pacman-key --populate archlinux
# This step is impossible unattended; if it must be unattended, use:
#curl "$URL/pacman.conf" > ~/pacman.conf
# then (skipping the `pacman-key --populate` step):
#pacman --noconfirm --config ~/pacman.conf OPTIONS

echo "Upgrading system"; read
pacman -Syu --noconfirm
pacman -Syu --noconfirm
pacman -S --noconfirm base-devel tar htop tmux vim git nginx #postgresql #redis

echo "Configuring user: root"; read
passwd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "Configuring user: deployer"; read
useradd -m -g users -G wheel -s /bin/bash deployer
passwd deployer
chown -R deployer:users /home/deployer
chmod a+rx /home/deployer
su deployer
cd ~
echo ":: config..."
curl "$URL/home.tar" | tar xv     # Includes terminfo, ssh authorized_keys, and bashrc
echo ":: ssh..."
ssh-keygen -t rsa -C "$EMAIL" -f ~/.ssh/id_rsa
echo ":: git..."
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
echo "Setting up ruby"; read
curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
rbenv install 1.9.3-p194
rbenv global 1.9.3-p194
rbenv bootstrap
rbenv rehash
exit

echo "Setting up nginx"; read
cd /etc/nginx
mkdir sites-available
mkdir sites-enabled
mkdir conf
curl "$URL/nginx/nginx.conf" > nginx.conf
curl "$URL/nginx/mime.types" > mime.types
curl "$URL/nginx/default.conf" > sites-available/default.conf
cd conf; curl -O "$URL/nginx/{cache-busting,cross-domain-ajax,cross-domain-fonts,expires,h5bp,no-transform,protect-system-files,x-ua-compatible}.conf"
systemctl enable nginx
systemctl start nginx

#echo "Setting up postgres"; read
#chown -R postgres /var/lib/postgres/
#su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"
#su - postgres -c "createuser -s deployer"
#mkdir /run/postgresql
#chown postgres /run/postgresql/
#systemctl enable postgresql
#systemctl start postgresql
#echo "Maybe add a password for the deployer postgres user?"

#echo "Setting up redis"; read
#systemctl enable redis
#systemctl start redis

echo "Done!"
echo "Remember to add deployer's key to github:"
cat ~deployer/.ssh/id_rsa.pub
