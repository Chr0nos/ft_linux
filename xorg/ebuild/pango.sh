build() {
	VERSION="1.42.0"
	URL="http://ftp.gnome.org/pub/gnome/sources/pango/1.42/pango-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	mkdir build &&
	cd    build &&
	meson --prefix=/usr --sysconfdir=/etc .. &&	ninja && ninja-install
	cleanup
}
