source $EBUILDS/xorg.sh

build() {
	PKG=xcb-util
	VERSION=0.4.0
	URL=https://xcb.freedesktop.org/dist/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG bz2
	./configure $XORG_CONFIG
	compile $PKG-$VERSION
	make install
}
