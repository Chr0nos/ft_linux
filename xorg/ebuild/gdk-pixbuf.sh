build() {
	VERSION="2.36.11"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.36/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr --with-x11 && compile $PKG-$VERSION && make install
	cleanup
}
