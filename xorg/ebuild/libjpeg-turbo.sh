build() {
	VERSION="1.5.3"
	URL="https://downloads.sourceforge.net/$PKG/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	./configure --prefix=/usr           \
				--mandir=/usr/share/man \
				--with-jpeg8            \
				--disable-static        \
				--docdir=/usr/share/doc/$PKG-$VERSION
	compile $PKG-$VERSION
	make install
	cleanup
}
