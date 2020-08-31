#!/bin/bash
#************************************************#
#                   wume		                 #
#           written by Ripx80			         #
#                February 22, 2011               #
#                                                #
#           Creating WuRes from Stage            #
#************************************************#


#**********Notice*********#
# check your mksquashfs version. 4.0!
# you need xz suppord for sysres not lzma!
# check that your filesystem is not ntfs fat or btrfs!
#*************************#

DEST='/home/wures'
STAGE='./stage-i686.tar.bz2'
UFILE='./wucustom.sh'
UU='./update_useflags.py'
GM='GENTOO_MIRRORS="http://192.168.77.1:81/ http://ftp.halifax.rwth-aachen.de/gentoo/"'
SM='SYNC="rsync://192.168.77.1/gentoo-portage"'
TAR='/var/www/localhost/htdocs/wufac/src/base/portage1.tar.lzma'
CONFIG='./wures_kernel_conf'

function load_modules(){
	echo "...load modules"
	modprobe squashfs
	check $? 2
}

function extract(){
	echo "...extract stage"
	test -d $DEST || mkdir -p $DEST/files
	test -d $DEST/isoroot || mkdir -p $DEST/isoroot
	test $(mount | grep "$DEST/files/dev" | wc -l) -gt 0 && umount $DEST/files/dev
	test $(mount | grep "$DEST/files/proc" | wc -l) -gt 0 && umount $DEST/files/proc
	test $(ls $DEST/isoroot | wc -l) -gt 0 && rm -r $DEST/isoroot/*
	test $(ls $DEST/files | wc -l) -gt 0 && rm -r $DEST/files/*

	tar -xpf $STAGE -C $DEST/files
	echo "...all files are copy"
}

function customize(){
	echo "...customize the wu system"
	test -d $DEST/files/usr/portage || mkdir -p $DEST/files/usr/portage
	[[ $TAR ]] && tar -xf $TAR -C $DEST/files/usr/portage
	{
	echo "$SM"
	echo 'PORTDIR="/usr/portage"'
	echo "CONFIG_PROTECT=\"*\""
	echo "$GM"
	echo 'ACCEPT_LICENSE="*"'
	echo 'EMERGE_DEFAULT_OPTS="--quiet-build=y --quiet-unmerge-warn"'
	echo 'FEATURES="-sandbox -fixlafiles"'
	}>>$DEST/files/etc/make.conf
	cp $UU $DEST/files/tmp

	mount -o bind /dev $DEST/files/dev
	mkdir $DEST/files/tmp/isolinux
	mount -o bind $DEST/isolinux $DEST/files/tmp/isolinux
	mount -t proc none $DEST/files/proc
	echo "...copy customize file to system"
	cp $UFILE $DEST/files/tmp/
	check $? 6
	chmod +x $DEST/files/tmp/$(basename $UFILE)
	echo "...chroot into system and execute the file"

	cp $CONFIG $DEST/files/usr/src/konfig

	chroot $DEST/files/ /bin/bash -c "/bin/bash '/tmp/$(basename $UFILE)'"
	check $? 7
	echo "...cleaning up"

	exit
	umount $DEST/files/tmp/isolinux
	rm $DEST/files/tmp/*
	rm -r $DEST/files/usr/portage/*
	umount $DEST/files/proc/
	check $? 8
	umount $DEST/files/dev/
	check $? 9
	#sed 'N;$!P;$!D;$d' $DEST/files/etc/make.conf > $DEST/files/tmp/make.conf
	#mv $DEST/files/tmp/make.conf $DEST/files/etc/
	echo "...your wu system is ready to squash"
}

function squashfs(){
	echo "...create the sysrcd.dat this take a long time"
	test $(mount | grep "$DEST/files/dev" | wc -l) -gt 0 && umount $DEST/files/dev
	test $(mount | grep "$DEST/files/proc" | wc -l) -gt 0 && umount $DEST/files/proc
	mksquashfs $DEST/files $DEST/isoroot/sysrcd.dat
	check $? 10
	md5sum $DEST/isoroot/sysrcd.dat >$DEST/isoroot/sysrcd.md5
	chmod 666 $DEST/isoroot/sysrcd.{dat,md5}
	echo "...your system is ready!"
}

function check(){
	code=$1
	if [ ! $code -eq 0 ]
	  then
	  	err="FATAL ERROR: "
		case $2 in
			1)  errn="cannot load module loop";;
			2)  errn="cannot load module squashfs";;
			3)  errn="cannot mount ISO";;
			4)  errn="files from iso cannot copy";;
			5)  errn="files from squash cannot copy";;
			6)  errn="cannot copy customize file to system";;
			7)  errn="chroot failed!";;
			8)  errn="cannot unmount proc";;
			9)	errn="cannot unmount dev";;
			10) errn="cannot create squashfs";;
			11) errn="cannot set keymap";;
			12) errn="no rsync or tarball are specified";;
			13) errn="no customisation file given or not found";;
			14) errn="unkown Option";;
			15) errn="you need root access";;
			16) errn="you need the programm mksquashfs!"
		esac
		echo "$err$errn"
		exit $code
	fi
}

load_modules
extract
customize
#squashfs
