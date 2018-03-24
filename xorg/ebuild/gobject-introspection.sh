build() {
	PKG="gobject-introspection"
	VERSION="1.54.1"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/1.54/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr    \
				--disable-static \
				--with-python=/usr/bin/python3
	compile $PKG-$VERSION
	make install
	cleanup
}
