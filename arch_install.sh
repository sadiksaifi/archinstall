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
sleep 2
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
arch-chroot /mnt
exit
