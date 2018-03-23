build() {
	PKG="libdrm"
	VERSION="2.4.91"
	URL="https://dri.freedesktop.org/$PKG/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	mkdir -v build
	cd build
	meson --prefix=$XORG_PREFIX -Dudev=true && ninja && ninja-install
}
