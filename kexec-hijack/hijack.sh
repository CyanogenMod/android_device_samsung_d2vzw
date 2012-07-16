#!/system/bin/sh

export PATH="/system/xbin:/sbin:/system/bin:${PATH}"

# passthrough if we're in kexec mode
if [ "$(getprop ro.bootmode)" == "kexec" ] ; then
	if [ "$(basename ${0})" == "hijack.sh" ] ; then
		echo "hijack.sh should not be called directly"
	else
		"${0}.bin" $@
	fi
else
	# copy update package to /cache
	cp /system/etc/kexec-boot.zip /cache

	# tell recovery to boot it
	mkdir -p /cache/recovery
	echo "--update_package=/cache/kexec-boot.zip" \
		> /cache/recovery/command

	# kill all the services we can
	for i in $(getprop | grep init.svc | sed -r 's/^\[init\.svc\.(.+)\]:.*$/\1/'); do
		# stop this service (or try to anyway)
		stop ${i}
	done

	# remount all block filesystems read-only
	for i in $(mount | grep /dev/block | awk '{print $3}') ; do
		mount -o remount,ro ${i}
	done

	# sync
	sync

	# reboot
	reboot recovery
fi
