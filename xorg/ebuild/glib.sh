build() {
	PKG="glib"
	VERSION="2.56.0"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.56/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr      \
				--with-pcre=system \
				--with-python=/usr/bin/python3 &&
		compile $PKG-$VERSION
	make install
	cleanup $PKG $VERSION
}
