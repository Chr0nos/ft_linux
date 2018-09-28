build() {
	PKG="gdb"
	VERSION="8.1"
	EXT="xz"
	URL="https://ftp.gnu.org/gnu/$PKG/$PKG-$VERSION.tar.xz"
	lprepair
	./configure --prefix=$XORG_PREFIX --with-system-readline --without-guile &&
		compile $PKG-$VERSION 2 && make -C gdb install && cleanup
}
