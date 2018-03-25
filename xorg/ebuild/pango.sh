build() {
	VERSION="1.40.14"
	URL="http://ftp.gnome.org/pub/gnome/sources/pango/1.40/pango-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	mkdir build &&
	cd    build &&
	meson --prefix=/usr --sysconfdir=/etc .. &&	ninja && ninja-install
	cleanup
}
