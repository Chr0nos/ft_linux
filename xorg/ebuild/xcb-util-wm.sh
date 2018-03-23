build() {
	PKG=xcb-util-wm
	VERSION=0.4.1
	URL=https://xcb.freedesktop.org/dist/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure $XORG_CONFIG
	compile $PKG-$VERSION
	make install
}
