#!/bin/bash

printf '\033c'
cd $HOME

[ -d "$HOME/.config/share" ] || mkdir -p $HOME/.config
[ -d "$HOME/.local" ] || mkdir -p $HOME/.local/share
[ -d "$HOME/.local/src" ] || mkdir -p $HOME/.local/src
[ -d "$HOME/Downloads" ] || mkdir -p $HOME/Downloads
[ -d "$HOME/Documents" ] || mkdir -p $HOME/Documents
[ -d "$HOME/Pictures" ] || mkdir -p $HOME/Pictures
[ -d "$HOME/Projects" ] || mkdir -p $HOME/Projects
[ -d "$HOME/Music" ] || mkdir -p $HOME/Music
[ -d "$HOME/Videos" ] || mkdir -p $HOME/Videos
[ -d "$HOME/Repos" ] || mkdir -p $HOME/Repos

zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)

git clone https://github.com/sadikeey/dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
stow */
cd $HOME

git clone https://github.com/sadikeey/dmenu.git $HOME/.local/src/dmenu
cd $HOME/.local/src/dmenu
sudo make clean install
cd $HOME

rm -rf $HOME/.config/emacs
git clone https://github.com/sadikeey/emacs.git $HOME/.config/emacs
rm -rf $HOME/.emacs.d

[ -d "/etc/X11/xorg.conf.d" ] || sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp $HOME/.dotfiles/.misc/configs/etc-X11-xorg.conf.d/* /etc/X11/xorg.conf.d/

git clone --depth=1 https://aur.archlinux.org/paru-bin.git $HOME/paru-bin
cd $HOME/paru-bin
makepkg -si
cd $HOME
rm -rf $HOME/paru-bin

paru -S devour google-java-format nodejs-neovim dmenu-bluetooth

cd $HOME/.dotfiles
git remote set-url --push origin git@github.com:sadikeey/dotfiles.git

cd $HOME/.local/src/dmenu
git remote set-url --push origin git@github.com:sadikeey/dmenu.git

cd $HOME/.config/emacs
git remote set-url --push origin git@github.com:sadikeey/emacs.git
cd $HOME

cp $HOME/.dotfiles/.misc/wall.jpg $HOME/.config/

rm $HOME/bash*
mv $HOME/.icons $HOME/.local/share/icons

echo "##############################################"
echo "##    Enter your username for autologin:    ##"
echo "##############################################"
read $username

[ -d "/etc/systemd/system/getty@tty1.service.d/" ] || sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo echo "[Services]" > /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo echo "ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin $username %I $TERM" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo echo "Type=simple" >> /etc/systemd/system/getty@tty1.service.d/autologin.conf

echo "#################################################"
echo "## You have successfully installed the system! ##"
echo "#################################################"
sleep 2
exit
