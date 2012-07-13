#!/sbin/sh

export PATH="/sbin:/tmp:${PATH}"

# remount partitions read-only
mount -o remount,ro /system
mount -o remount,ro /data
mount -o remount,ro /cache

# load kexec
kexec \
	--append="$(cat /proc/cmdline)" \
	--load-hardboot \
	--mem-min=0xa0000000 \
	--initrd=/tmp/ramdisk.img \
	/tmp/kernel

# sync the filesystems
sync

# boot kexec
kexec -e
