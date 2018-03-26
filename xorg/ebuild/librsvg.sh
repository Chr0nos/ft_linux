build() {
	VERSION="2.42.2"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.42/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr --enable-vala --disable-static &&
		compile $PKG-$VERSION && make install && cleanup
}
