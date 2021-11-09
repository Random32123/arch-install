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



