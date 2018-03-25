build() {
	VERSION="2.26.2"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.26/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr --sysconfdir=/etc &&
		compile $PKG-$VERSION && make install && cleanup
}
