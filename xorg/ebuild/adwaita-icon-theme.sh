build() {
	VERSION="3.20"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/3.20/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && cleanup
}
