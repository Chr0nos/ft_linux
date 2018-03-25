build() {
	VERSION="0.12.0"
	URL="http://archive.xfce.org/src/xfce/$PKG/0.12/$PKG-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	./configure --prefix=/usr --sysconfdir=/etc &&
		compile $PKG-$VERSION && make install && cleanup
}
