build() {
	VERSION="1.7.0"
	URL="http://archive.xfce.org/src/xfce/thunar/1.7/$PKG-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/$PKG-$VERSION &&
		compile $PKG-$VERSION && make install && cleanup
}
