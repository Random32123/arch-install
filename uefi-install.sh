#! /bin/sh

# (Ex. America/Chicago)
read -p 'Timezone: ' timezonevar
timedatectl set-timezone $timezonevar

fdisk -l
read -p 'Root Drive: ' drivevar
fdisk $drivevar
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  g # clear the in memory partition table
  n # new partition
  1 # partition number 1
    # default - start at beginning of disk 
  +512M # 512 MB boot parttion
  t # changes type of partition
    # selects most recent partition
  1 # changes to EFI partition
  n # new partition
  2 # partition number 2
    # default, start immediately after proceding partition
  +2G # 2 GB of swap space
  t # changes type of partition
    # selects most recent partition
  19 # changes to Swap Partition
  n # new partition
  3 # partion number 3
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  t # changes type of partition
    # selects most recent partition
  20 # changes to linux filesystem
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

echo 'Root Partition is always parition 3, Swap is always parition 2, EFI is always partition 1'
read -p 'Root Parition (eg. /dev/sda3): ' rootvar
read -p 'Swap Partition (eg. /dev/sda2): ' swapvar
read -p 'EFI Partition (eg. /dev/sda1): ' efivar

mount $rootvar /mnt
swapon $swapvar

# Package Installation
pacstrap /mnt base linux linux-lts linux-headers linux-lts-headers linux-firmware networkmanager nano vim man-db

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

read -p 'Hostname: ' hostnamevar
echo $hostnamevar >> /etc/hostname

pacman -S grub efibootmgr dosfstools os-prober mtools

mkdir /boot/EFI
mount $efivar /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
mkdir /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

passwd

echo "Arch Installed! There are 3 more commands to finish,"
echo "exit"
echo "umount -a"
echo "reboot"
