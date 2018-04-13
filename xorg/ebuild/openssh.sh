configure_pkg() {
	echo "PermitRootLogin no" >> /etc/ssh/sshd_config
}

build() {
	VERSION="7.7p1"
	EXT="gz"
	URL="http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/$PKG-$VERSION.tar.$EXT"
	PATCH="http://www.linuxfromscratch.org/patches/blfs/svn/$PKG-$VERSION-$PKG-1.1.0-1.patch"
	CFG="--sysconfdir=/etc/ssh --with-md5-passwords --with-privsep-path=/var/lib/sshd"
	lprepair

	install  -v -m700 -d /var/lib/sshd &&
	chown    -v root:sys /var/lib/sshd &&

	groupadd -g 50 sshd        &&
	useradd		-c 'sshd PrivSep' \
				-d /var/lib/sshd  \
				-g sshd           \
				-s /bin/false     \
				-u 50 sshd
	wget --no-check-certificate $PATCH &&
		patch -Np1 -i openssh-7.7p1-openssl-1.1.0-1.patch &&
		./configure --prefix=/usr $CFG &&
		compile $PKG &&
		make install &&
		install -v -m755    contrib/ssh-copy-id /usr/bin &&
		install -v -m644    contrib/ssh-copy-id.1 /usr/share/man/man1 &&
		install -v -m755 -d /usr/share/doc/openssh-7.7p1 &&
		install -v -m644    INSTALL LICENCE OVERVIEW README* /usr/share/doc/openssh-7.7p1 &&
		configure_pkg &&
		cleanup
}
