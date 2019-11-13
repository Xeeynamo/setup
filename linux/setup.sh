hwclock --systohc
ln -sf /usr/share/zoneinfo/Europe/London
echo en_GB.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo KEYMAP=uk >> /etc/vconsole.conf
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m xeeynamo
usermod -aG wheel xeeynamo
passwd
passwd xeeynamo
exit
