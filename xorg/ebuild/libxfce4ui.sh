build() {
	VERSION="4.12.1"
	URL="http://archive.xfce.org/src/xfce/$PKG/4.12/$PKG-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	./configure --prefix=/usr --sysconfdir=/etc &&
		compile $PKG-$VERSION && make install && cleanup
}
