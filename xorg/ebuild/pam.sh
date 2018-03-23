# http://fr.linuxfromscratch.org/view/blfs-systemd-svn/postlfs/linux-pam.html

build() {
	PKG="pam"
	VERSION="1.3.0"
	URL="http://linux-pam.org/library/Linux-PAM-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG bz2
	./configure --prefix=/usr                    \
				--sysconfdir=/etc                \
				--libdir=/usr/lib                \
				--disable-regenerate-docu        \
				--enable-securedir=/lib/security \
				--docdir=/usr/share/doc/Linux-PAM-$VERSION &&
	compile $PKG-$VERSION
	if [ -d /etc/security ]; then
		echo "making backup of current files, just in case..."
		tar -cf /tmp/security.bak /etc/security
		tar -cf /tmp/environement.bak /etc/environement
	fi
	if [ !-f /usr/bin/pam_tally  ]; then
		echo "First inallation detected"
		cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF

		cat > /etc/pam.d/system-account << "EOF" &&
# Begin /etc/pam.d/system-account
account   required    pam_unix.so
# End /etc/pam.d/system-account
EOF

		cat > /etc/pam.d/system-auth << "EOF" &&
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
EOF

	cat > /etc/pam.d/system-session << "EOF"
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
	fi
	make install
	chmod -v 4755 /sbin/unix_chkpwd &&

	for file in pam pam_misc pamc
	do
		mv -v /usr/lib/lib${file}.so.* /lib &&
		ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
	done
}
