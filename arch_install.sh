#!/bin/bash

printf '\033c'
echo "Welcome to SDK's arch installer script"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 8/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true

lsblk
echo "Enter the drive and create root(50G+), efi(512M+), home(rest), swap(RAMx2G+) partition: "
read drive
cfdisk $drive 
lsblk

echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition 

echo "Enter EFI partition: "
read efipartition
mkfs.vfat -F 32 $efipartition

echo "Enter Home partition: "
read homepartition
mkfs.ext4 $homepartition

echo "Enter Swap partition: "
read swappartition
mkfs.swap $swappartition
swapon $swappartition

mount $partition /mnt 
mkdir -p /mnt/boot/EFI
mkdir -p /mnt/home
mount $efipartition /mnt/boot/EFI 
mount $homepartition /mnt/home

pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
cp pkglist.txt /mnt
arch-chroot /mnt ./arch_install2.sh
exit

printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 8/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_CTYPE=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd

pacman --noconfirm -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

pacman --needed --ask 4 -Sy - < pkglist.txt || error "Failed to install required packages."

systemctl enable NetworkManager 
systemctl enable libvirtd
systemctl enable tlp 
systemctl enable auto-cpufreq

rm /bin/sh
ln -s dash /bin/sh
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/zsh $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username

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
sudo make -C ~/.local/src/dmenu install

[ -d "/etc/X11/xorg.conf.d" ] || sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp $HOME/.dotfiles/.misc/configs/etc-X11-xorg.conf.d/* /etc/X11/xorg.conf.d/

git clone --depth=1 https://aur.archlinux.org/paru-bin.git $HOME/paru-bin
cd $HOME/paru-bin
sudo makepkg -si
cd $HOME
rm -rf $HOME/paru-bin

paru -S devour google-java-format nodejs-neovim

[ -d "/etc/systemd/system/getty@tty1.service.d/" ] || sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo echo "[Service]"
sudo echo "ExecStart="
sudo echo "ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin sdk %I $TERM"
sudo echo "Type=simple"

# Setting Wallpaper
cp $HOME/.dotfiles/.misc/wall.jpg $HOME/.config/

echo "#################################################"
echo "## You have successfully installed the system! ##"
echo "#################################################"

exit
