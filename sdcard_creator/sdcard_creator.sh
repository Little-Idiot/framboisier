#!/bin/bash
([[ 0 -ne $EUID ]] || [[ -z $1 ]]) && { printf "usage: sudo %s <sdcard_layout>\n"; exit -1; }
set -x



################################################################################
# settings 
################################################################################
readonly SDcard_device="/dev/sdc"
readonly SDcard_device_boot="$SDcard_device""1"
readonly SDcard_device_root="$SDcard_device""2"

# readonly SDcard_device="/dev/mmcblk0"
# readonly SDcard_device_boot="$SDcard_device""p1"
# readonly SDcard_device_root="$SDcard_device""p2"

readonly SDcard_root="/tmp/SDcard_root"
readonly SDcard_boot="/tmp/SDcard_boot"

readonly SDcard_layout="$1"



################################################################################
# pi-archlinux: download
################################################################################
if [ ! -f "/tmp/ArchLinuxARM-rpi-2-latest.tar.gz" ]; then

	wget --directory-prefix=/tmp "http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz"
	[[ 0 -ne $? ]] && { printf "error: fail to download ArchLinuxARM latest release (error: %d)\n" $?; exit -2; }

fi



################################################################################
# pi-archlinux: sdcard preparation
################################################################################
[[ ! -f "$SDcard_layout" ]] && { printf "error: file \"%s\" not found\n" $SDcard_layout; exit -3; }


sfdisk "$SDcard_device" < "$SDcard_layout"
[[ 0 -ne $? ]] && { printf "error: fail to format SDcard (exit: %d)" $?; exit -4; }


mkfs.vfat "$SDcard_device_boot"
[[ 0 -ne $? ]] && { printf "error: fail to create \"vFAT\" filesystem for \"boot\" partition (exit: %d)\n" $?; exit -5; }

yes |mkfs.ext4 -q "$SDcard_device_root"
[[ 0 -ne $? ]] && { printf "error: fail to create \"ext4\" filesystem for \"root\" partition (exit: %d)\n" $?; exit -6; }

[[ ! -d "$SDcard_boot" ]] && mkdir "$SDcard_boot"
[[ ! -d "$SDcard_root" ]] && mkdir "$SDcard_root"

mount "$SDcard_device_boot" "$SDcard_boot"
[[ 0 -ne $? ]] && { printf "error: fail to mount \"%s\" on \"%s\"\n" "$SDcard_device_boot" "$SDcard_boot"; exit -7; }

mount "$SDcard_device_root" "$SDcard_root"
[[ 0 -ne $? ]] && { printf "error: fail to mount \"%s\" on \"%s\"\n" "$SDcard_device_root" "$SDcard_root"; exit -8; }



################################################################################
# pi-archlinux: installation
################################################################################
tar --extract --preserve-permissions --file="/tmp/ArchLinuxARM-rpi-2-latest.tar.gz" --directory="$SDcard_boot" --strip-components=2 "./boot" 2> /dev/null
[[ 0 -ne $? ]] && { printf "error: fail to extract ressources to \"%s\"\n" "$SDcard_boot"; exit -9; }

tar --extract --preserve-permissions --file="/tmp/ArchLinuxARM-rpi-2-latest.tar.gz" --directory="$SDcard_root" --exclude="./boot" 2> /dev/null
[[ 0 -ne $? ]] && { printf "error: fail to extract ressources to \"%s\"\n" "$SDcard_root"; exit -10; }

sync

umount "$SDcard_device_boot"
[[ 0 -ne $? ]] && printf "warning: fail to unmount \"%s\"\n" "$SDcard_boot"

umount "$SDcard_device_root"
[[ 0 -ne $? ]] && printf "warning: fail to unmount \"%s\"\n" "$SDcard_root"



printf "info: SDcard prepared\n"
exit 0
