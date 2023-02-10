#!/bin/bash

printf '\033c'
echo "#######################################################"
echo "##    Welcome to SDK's arch linux install script.    ##"
echo "#######################################################"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true

lsblk
echo "Enter the drive and create root(50G+), efi(512M+), home(rest), swap(RAMx2G+) partition: "
read drive
cfdisk $drive 
sleep 2
lsblk

echo "Enter the Root partition as (/dev/drive_name): "
read partition
mkfs.ext4 $partition 

echo "Enter EFI partition as (/dev/drive_name): "
read efipartition
mkfs.vfat -F 32 $efipartition

echo "Enter Home partition as (/dev/drive_name): "
read homepartition
mkfs.ext4 $homepartition

echo "Enter Swap partition as (/dev/drive_name): "
read swappartition
mkswap $swappartition
swapon $swappartition

mount $partition /mnt 
mkdir -p /mnt/boot/EFI
mkdir -p /mnt/home
mount $efipartition /mnt/boot/EFI 
mount $homepartition /mnt/home

pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
cp pkglist.txt /mnt
cp arch_install2.sh /mnt
cp arch_install3.sh /mnt
echo "##########################################################################################"
echo "##    Now you are gonna chroot into new installed system so execute arch_install2.sh    ##"
echo "##########################################################################################"
arch-chroot /mnt
exit
