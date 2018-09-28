build() {
	PKG="gdb"
	VERSION="8.1"
	URL="https://ftp.gnu.org/gnu/$PKG/$PKG-$VERSION.tar.xz"
	lprepair
	./configure --prefix=$XORG_PREFIX --with-system-readline --without-guile &&
		compile && make -C gdb install && cleanup
}
