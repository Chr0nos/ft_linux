build() {
	VERSION="0.110"
	URL="https://dbus.freedesktop.org/releases/$PKG/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	./configure --prefix=/usr     \
				--sysconfdir=/etc \
				--disable-static && compile $PKG-$VERSION &&
			make install && cleanup
}
