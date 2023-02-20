#!/bin/bash

printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_CTYPE=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

echo "############################"
echo "##    Enter Hostname:     ##"
echo "############################"
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
echo "################################"
echo "##    Enter root password:    ##"
echo "################################"
passwd

pacman --noconfirm -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

pacman --needed --ask 4 -Syy - < pkglist.txt || error "Failed to install required packages."

systemctl enable NetworkManager
systemctl enable libvirtd
systemctl enable tlp
systemctl enable auto-cpufreq
systemctl enable bluetooth

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "###########################"
echo "##    Enter Username:    ##"
echo "###########################"
read username
useradd -m $username
echo "##################################"
echo "##    Enter User's Password:    ##"
echo "##################################"
passwd $username
usermod -aG wheel,audio,video,storage $username
usermod -G libvirt -a $username
chsh -s /usr/bin/zsh $username
[ -d "/home/$username/" ] || mkdir -p /home/$username
cp arch_install3.sh /home/$username/
echo "###########################################################################################"
echo "##    Pre-installation part2 has complete, so now reboot and execute arch_install3.sh    ##"
echo "###########################################################################################"
exit
