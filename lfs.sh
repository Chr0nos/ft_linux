#!/bin/sh
source ./config.sh

checkroot() {
	if [ $(whoami) != "root" ]; then
		echo "please run me as root"
		exit 1
	fi
}

sysmount() {
	echo "Creating binds"
	mkdir -pv $LFS/{dev,proc,sys,run}
	mknod -m 600 $LFS/dev/console c 5 1
	mknod -m 666 $LFS/dev/null c 1 3
	mount -vo bind /dev $LFS/dev
	mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
	mount -vt proc proc $LFS/proc
	mount -vt sysfs sysfs $LFS/sys
	mount -vt tmpfs tmpfs $LFS/run
	if [ -h $LFS/dev/shm ]; then
		mkdir -pv $LFS/$(readlink $LFS/dev/shm)
	fi
	echo "sysmount done"
}

chexec() {
	cp -v ./chroot.sh $LFS/chroot.sh
	chmod +x $LFS/chroot.sh
	chroot "$LFS" /tools/bin/env -i 					\
		HOME=/root                  					\
		TERM="$TERM"           						    \
		PS1='(lfs chroot) \u:\w\$ ' 					\
		PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin	\
		/chroot.sh
}

checkroot
# 6.0
# sysmount
chexec ./chroot.sh

