#! /bin/bash
# 
# This script will take a fresh install of Arch Linux and set it up with ruby
# and nginx, as well as the usual necessities. It must be run interactively.
# 
#              ==================
#              IMPORTANT WARNING!
#              ==================
# 
# This script will add MY ssh public key to YOUR list of authorized keys. In
# other words, after the script has run, I WILL BE ABLE TO GAIN ACCESS TO YOUR
# SERVER!
# 
# This is because I use this script for provisioning my own server instances.
# If you want to use it in production, change $URL to a location you control
# (with your own public key in "authorized_keys"). Otherwise, ENSURE THAT YOU
# DELETE "~deployer/.ssh/authorized_keys" after setup is finished.
#
# See github.org/asayers/provision/ for auxiliary files

# You should probably change these
export HOSTNAME="vanaheimr"
export NAME="Alex Sayers"
export EMAIL="alex.sayers@gmail.com"
# config files will be downloaded from here. You can leave this as-is, or set
# up your own location.
export URL="https://raw.github.com/asayers/provision/master"

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
# This step is impossible unattended; if it must be unattended, use:
#curl "$URL/pacman.conf" > ~/pacman.conf
# then (skipping the `pacman-key --populate` step):
#pacman --noconfirm --config ~/pacman.conf OPTIONS

echo "Upgrading system"
pacman -Syu --noconfirm
pacman -Syu --noconfirm
pacman -S --noconfirm base-devel sudo mosh tar htop tmux zsh vim git nginx nodejs mongodb postgresql redis

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
  # home.tar includes terminfo, ssh authorized_keys, and bashrc. Note that this
  # line may introduce a SERIOUS SECURITY VULNERABILITY. See information at the
  # top.
  curl "$URL/home.tar" | tar xv
  echo ":: ssh..."
  ssh-keygen -t rsa -C "$EMAIL" -f ~/.ssh/id_rsa
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
cd /etc/nginx
curl "$URL/nginx.tar" | tar xv     # Includes h5bp nginx conf
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
echo "Maybe add a password for the deployer postgres user?"

echo "Setting up redis"
systemctl enable redis
systemctl start redis

echo "Setting up mongo"
systemctl enable mongodb
systemctl start mongodb

echo "Done!"
echo "Remember to add deployer's key to github:"
cat ~deployer/.ssh/id_rsa.pub
