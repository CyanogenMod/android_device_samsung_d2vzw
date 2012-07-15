#!/sbin/sh

export PATH="/sbin:/tmp:${PATH}"

# remove the command file from cache so we don't get stuck auto-flashing
# back and forth forever (generally this would get removed in
# finish_recovery() but that won't get called due to kexec rebooting
# the system
rm -f /cache/recovery/command

# remount all partitions read-only to ensure data integrity
for i in $(mount | grep /dev/block | awk '{print $3}') ; do
	mount -o remount,ro ${i}
done

# set our cmdline:
#   get original cmdline
#   remove boot_recovery
#   add kexec boot mode
cmdline="$(cat /proc/cmdline)"
cmdline="$(echo "${cmdline}" | sed -r 's/androidboot\.boot_recovery=([^ ]*)( .*)?$/\2/')"
cmdline="${cmdline} androidboot.mode=kexec"

# load kexec with our new information
kexec \
	--append="${cmdline}" \
	--load-hardboot \
	--mem-min=0xa0000000 \
	--initrd=/tmp/ramdisk.img \
	/tmp/kernel

# sync the filesystems
sync

# boot kexec
kexec -e
