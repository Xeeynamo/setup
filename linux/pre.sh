#ip link
loadkeys uk
timedatectl set-ntp true
printf "g\nn\n\n\n+100M\nn\n\n\n\nw\n" | fdisk /dev/sda
mkfs.ext4 /dev/sda2
mkfs.fat -F32 /dev/sda1
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi
pacstrap /mnt base linux linux-firmware grub efibootmgr base-devel git nano dhcpcd openssh systemd ufw wget curl
genfstab -U /mnt >> /mnt/etc/fstab
curl https://raw.githubusercontent.com/Xeeynamo/setup/master/linux/setup.sh | arch-chroot /mnt
umount -R /mnt
reboot
