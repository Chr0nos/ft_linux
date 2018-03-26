build() {
	VERSION="3.26"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/3.26/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && cleanup
}
