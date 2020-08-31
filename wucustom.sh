#!/bin/bash

function wume(){
	emerge --sync
	emerge -1 portage
	{
		echo "net-misc/wget ssl"
		echo "net-misc/openssh hpn"
		echo "sys-devel/gcc cxx"
	}>>/etc/portage/package.use
	{
		echo ">=dev-lang/python-3.0"
	}>>/etc/portage/package.mask

	python /tmp/update_useflags.py --outfile=/etc/make.conf --globaluse="minimal"

	echo 'nameserver 8.8.8.8' >>/etc/resolv.conf

	emerge -C dev-lang/python-3*
	emerge -C pam pambase
	emerge -N shadow
	#emerge -NuD world
	emerge -c
	emerge -1 portage-utils gentoo-sources
	emerge -1 app-arch/xz-utils net-misc/dhcpcd net-misc/openssh sys-fs/btrfs-progs sys-fs/dosfstools sys-fs/e2fsprogs sys-fs/hfsutils sys-fs/jfsutils sys-fs/lvm2 sys-fs/mdadm sys-fs/reiserfsprogs sys-fs/xfsprogs

	ln -s /usr/src/linux-* /usr/src/linux
	mv /usr/src/konfig /usr/src/linux/.config
	cd /usr/src/linux && make && make modules_install
	cp ./arch/x86/boot/bzImage /tmp/isolinux
	cd /root

	exit

	for i in $(qlist -IC x11-* app-text/*  dev-util/* app-editors/* app-emulation/* app-misc/* app-accessibility/* app-antivirus/* app-backup/* app-benchmarks/* app-cdr/* app-crypt/* app-forensics/* app-vim/* gnome-base/* media-fonts/* media-libs* net-analyzer/* net-dialup/* net-wireless/* sys-boot/* www-client/* www-servers/* xfce-base/* app-admin/* app-arch/* app-portage/* net-firewall/* net-fs/* net-ftp/* net-irc/* net-misc/* sys-apps/* sys-block/* sys-cluster/* sys-fs/* sys-process/* virtual/* sys-devel/* app-shells/* sys-kernel/* dev-lang/* dev-libs/* sys-libs/* dev-perl/* dev-python/* net-dns/* perl-core/* sys-auth/* net-libs/* dev-vcs/*)
	  do
		grep "$i" /tmp/wwlist || R="$R $i"
	done
	emerge -C $R

	echo "######deleting files#######"

	rm -rf /etc/xinetd.d
	rm -rf /var/cache/*
	rm -rf /var/log/*
	rm -rf /var/lib/gentoo
	rm -rf /var/tmp

	rm -rf /usr/share/man
	rm -rf /usr/share/bash-completion
	rm -rf /usr/share/pixmaps
	rm -rf /usr/share/applications

	rm -rf /usr/share/i18n
	rm -rf /usr/share/terminfo
	#mv /usr/share/keymaps/i386/qwertz/de-latin1-nodeadkeys.map /tmp/
	rm -rf /usr/share/keymaps/*
	mkdir -p /usr/share/keymaps/i386/qwertz/
	#mv /tmp/de-latin1-nodeadkeys.map /usr/share/keymaps/i386/qwertz/

	#mv /usr/share/consolefonts/default8x16.psfu /tmp/
	rm -rf /usr/share/consolefonts/*
	#mv /tmp/default8x16.psfu /usr/share/consolefonts/

	rm -rf /usr/share/misc
	rm -rf /usr/share/locale/
	rm -rf /usr/share/icu
	rm -rf /usr/share/mime
	rm -rf /usr/share/consoletrans
	rm -rf /usr/share/unimaps

	rm -rf /usr/share/info
	rm -rf /usr/share/doc

	rm -rf /usr/lib/locale
	rm -rf /usr/lib/gconv
}
#dev-libs/libxml2
#app-arch/cabextract
#dev-libs/lzo
#net-libs/libpcap
#net-libs/libtirpc
#sys-apps/debianutils
#sys-auth/pambase
#sys-libs/pam
#virtual/pager
#virtual/pam

#dev-libs/expat

#sys-process/psmisc
#sys-process/procps
#sys-libs/readline
#sys-apps/which
#sys-apps/sandbox
#sys-apps/findutils
#sys-apps/file
#sys-apps/acl
#app-admin/python-updater

#virtual/dev-manager
#virtual/editor
#virtual/init
#virtual/libc
#virtual/libffi
#virtual/libintl
#virtual/linux-sources
#virtual/os-headers
#virtual/package-manager
#virtual/ssh

function wwlist(){
cat >/tmp/wwlist << WWLIST
app-admin/eselect
app-admin/eselect-ctags

app-admin/eselect-python

app-arch/bzip2
app-arch/gzip

app-arch/tar
app-arch/xz-utils
app-editors/nano
app-misc/livecd-tools
app-shells/bash
dev-lang/python

sys-libs/ncurses

dev-libs/atk
dev-libs/elfutils

dev-libs/glib
dev-libs/gmp
dev-libs/libevent
dev-libs/libffi
dev-libs/libgcrypt
dev-libs/libgpg-error
dev-libs/libIDL
dev-libs/libpcre
dev-libs/libpthread-stubs

dev-libs/openssl
dev-libs/popt
dev-libs/mpfr
dev-libs/mpc

dev-python/argparse
dev-python/setuptools

net-libs/gnutls
net-libs/libnet

net-misc/dhcpcd
net-misc/openssh
net-misc/rsync
net-misc/wget

sys-apps/attr
sys-apps/baselayout
sys-apps/coreutils

sys-apps/gawk
sys-apps/grep
sys-apps/kbd
sys-apps/module-init-tools
sys-apps/net-tools
sys-apps/openrc
sys-apps/portage

sys-apps/sed
sys-apps/shadow
sys-apps/sysresccd-scripts
sys-apps/sysvinit
sys-apps/tcp-wrappers
sys-apps/util-linux

sys-devel/autoconf
sys-devel/autoconf-wrapper
sys-devel/automake
sys-devel/automake-wrapper
sys-devel/binutils
sys-devel/binutils-config
sys-devel/gcc
sys-devel/gcc-config
sys-devel/gnuconfig
sys-devel/libtool
sys-devel/m4
sys-devel/make
sys-devel/patch

sys-fs/btrfs-progs
sys-fs/dosfstools
sys-fs/e2fsprogs
sys-fs/hfsutils
sys-fs/jfsutils
sys-fs/lvm2
sys-fs/mdadm
sys-fs/reiserfsprogs
sys-fs/udev
sys-fs/xfsprogs

sys-kernel/linux-headers

sys-libs/e2fsprogs-libs
sys-libs/gdbm
sys-libs/glibc
sys-libs/libaal
sys-libs/libstdc++-v3

sys-libs/talloc
sys-libs/zlib

WWLIST
}
wwlist
wume
exit 0
