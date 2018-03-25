build() {
	VERSION="2.10.0"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.10/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && \
		cleanup
}
