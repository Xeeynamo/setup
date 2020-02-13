hwclock --systohc
ln -sf /usr/share/zoneinfo/Europe/London
echo en_GB.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo KEYMAP=uk >> /etc/vconsole.conf
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable sshd
systemctl enable dhcpcd
useradd -m xeeynamo
usermod -aG wheel xeeynamo

# Disable automatic core dumps
echo 'kernel.core_pattern=|/bin/false' > /etc/sysctl.d/50-coredump.conf

exit
