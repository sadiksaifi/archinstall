#!/bin/bash

printf '\033c'
cd $HOME

[ -d "$HOME/.config/share" ] || mkdir -p $HOME/.config
[ -d "$HOME/.local" ] || mkdir -p $HOME/.local/share
[ -d "$HOME/.local/src" ] || mkdir -p $HOME/.local/src
[ -d "$HOME/Downloads" ] || mkdir -p $HOME/Downloads
[ -d "$HOME/Documents" ] || mkdir -p $HOME/Documents
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

[ -d "/etc/X11/xorg.conf.d" ] || sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp $HOME/.dotfiles/.misc/configs/etc-X11-xorg.conf.d/* /etc/X11/xorg.conf.d/

git clone --depth=1 https://aur.archlinux.org/paru-bin.git $HOME/paru-bin
cd $HOME/paru-bin
makepkg -si
cd $HOME
rm -rf $HOME/paru-bin

paru -S devour google-java-format nodejs-neovim

[ -d "/etc/systemd/system/getty@tty1.service.d/" ] || sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo $HOME/.dotfiles/.misc/autologin.conf

# Setting Wallpaper
cp $HOME/.dotfiles/.misc/wall.jpg $HOME/.config/

echo "#################################################"
echo "## You have successfully installed the system! ##"
echo "#################################################"

exit
