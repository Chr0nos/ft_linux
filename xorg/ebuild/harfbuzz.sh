build() {
	VERSION="1.7.5"
	URL="https://www.freedesktop.org/software/$PKG/release/$PKG-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	./configure --prefix=/usr --with-gobject &&
		compile $PKG-$VERSION && make install && cleanup
}
