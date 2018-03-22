build() {
	PKG=xcb-util-image
	VERSION=0.4.0
	URL=https://xcb.freedesktop.org/dist/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION
	./configure $XORG_CONFIG
	compile $PKG-$VERSION
	make install
}
