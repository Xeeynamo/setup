if [ -z $DISK ]; then printf "\e[1;31mVariable DISK is not set (eg. DISK=/dev/sda). Setup process will now exit."; fi
DISK1="$DISK""1"
DISK2="$DISK""2"

#ip link
loadkeys uk
timedatectl set-ntp true
printf "g\nn\n\n\n+100M\nn\n\n\n\nw\n" | fdisk $DISK
mkfs.ext4 $DISK2
mkfs.fat -F32 $DISK1
mount $DISK2 /mnt
mkdir /mnt/efi
mount $DISK1 /mnt/efi
pacstrap /mnt base linux linux-firmware grub efibootmgr base-devel git nano dhcpcd openssh systemd ufw wget curl man-db man-pages xclip mtr whois
genfstab -U /mnt >> /mnt/etc/fstab
curl https://raw.githubusercontent.com/Xeeynamo/setup/master/linux/setup.sh | arch-chroot /mnt
umount -R /mnt/boot
umount -R /mnt
reboot
