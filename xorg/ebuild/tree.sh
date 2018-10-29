build() {
	PKG=tree
	EXT=tgz
	VERSION="1.7.0"
	URL="http://mama.indstate.edu/users/ice/tree/src/$PKG-$VERSION.$EXT"
	lprepair && lcompile &&
		make MANDIR=/usr/share/man/man1 install && chmod -v 644 /usr/share/man/man1/tree.1
}
