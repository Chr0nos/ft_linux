build() {
	PKG="atk"
	VERSION="2.28.1"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.28/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	mkdir -v build
	cd build
	meson --prefix=/usr && ninja && ninja install
	cleanup $PKG $VERSION
}
