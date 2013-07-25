#! /bin/bash
# 
# This script is designed to be run on a fresh install of Arch Linux. You are
# advised to check through it and comment out the things you don't want. By
# default it does basic setup, then installs and configures nginx, postgres,
# mongo, redis, ruby, and nodejs. As-is, it must be run interactively (although
# it can be run unattended - see comments in source).
# 
#              ===================
#               SECURITY WARNING!
#              ===================
# 
# This script populates your ~/.ssh/authorized_keys with the authorised keys
# for the Github account $GHUSER. This means that if a computer can push
# commits to github repos owned by $GHUSER, then by the time this script is
# done it will also be able to log into your machine! Be careful! If you enter
# an invalid username, your ~/.ssh/authorized_keys will be filled with garbage.

# See github.org/asayers/provision/ for the auxiliary files

# You should probably change these.
export HOSTNAME="vanaheimr"           # Desired hostname
export NAME="Alex Sayers"             # Your full name (for git config)
export EMAIL="alex.sayers@gmail.com"  # Your email (for ssh and git config)
export GHUSER=""                      # Your github username (for authorised SSH keys) - MAKE SURE THIS IS YOU!

# Config files will be downloaded from here. This can be left alone, but feel free to host your own configs.
export URL="https://raw.github.com/asayers/provision/master" # config files will be downloaded from here.


echo "Setting hostname to $HOSTNAME"
echo $HOSTNAME > /etc/hostname

echo "Setting locale to en_GB.UTF-8"
echo -e "en_GB.UTF-8 UTF-8\nen_US.UTF-8 UTF-8" > /etc/locale.gen
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
# This last step is impossible unattended. If you must run this script unattended you can skip it by running:
#curl "$URL/pacman.conf" > ~/pacman.conf
#alias pacman="pacman --noconfirm --config ~/pacman.conf"

echo "Installing AUR helper"
bash <(curl aur.sh) -si packer    # We're using packer, because it doesn't have AUR dependencies.

echo "Upgrading system"
pacman -Syu --noconfirm
pacman -Syu --noconfirm
pacman -S --noconfirm base-devel sudo mosh tar htop tmux zsh vim git nodejs

echo "Configuring user: root"
passwd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "Configuring user: deployer"
useradd -m -g users -G wheel -s /bin/zsh deployer
passwd deployer
chown -R deployer:users /home/deployer
chmod a+rx /home/deployer
cd /home/deployer
su deployer
  echo ":: config..."
  # home.tar includes terminfo, bashrc, zshrc, and tmux config.
  curl "$URL/home.tar" | tar xv
  echo ":: ssh..."
  ssh-keygen -t rsa -C "$EMAIL" -f ~/.ssh/id_rsa
  curl "https://github.com/"$GHUSER".keys" > .ssh/authorized_keys
  echo ":: git..."
  git config --global user.name "$NAME"
  git config --global user.email "$EMAIL"
  echo ":: ruby..."
  curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
  rbenv install 1.9.3-p194
  rbenv global 1.9.3-p194
  rbenv bootstrap
  rbenv rehash
exit

echo "Setting up nginx"
pacman -S --noconfirm nginx
cd /etc/nginx
curl "$URL/nginx.tar" | tar xv     # Includes h5bp nginx conf
systemctl enable nginx
systemctl start nginx

echo "Setting up postgres"
pacman -S --noconfirm postgresql
chown -R postgres /var/lib/postgres/
su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"
su - postgres -c "createuser -s deployer"
mkdir /run/postgresql
chown postgres /run/postgresql/
systemctl enable postgresql
systemctl start postgresql
echo "Maybe add a password for the deployer postgres user?"

echo "Setting up redis"
pacman -S --noconfirm redis
systemctl enable redis
systemctl start redis

echo "Setting up mongo"
pacman -S --noconfirm mongodb
systemctl enable mongodb
systemctl start mongodb

echo "Done!"
echo "Remember to add deployer's key to github:"
cat ~deployer/.ssh/id_rsa.pub
