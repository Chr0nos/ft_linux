build() {
	PKG="Python"
	VERSION="2.7.14"
	URL="https://www.python.org/ftp/python/$VERSION/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr       \
				--enable-shared     \
				--with-system-expat \
				--with-system-ffi   \
				--with-ensurepip=yes \
				--enable-unicode=ucs4
	compile $PKG-$VERSION
	make install
	chmod -v 755 /usr/lib/libpython2.7.so.1.0
}
