source $EBUILDS/xorg.sh

build() {
	PKG=xcb-proto
	VERSION=1.13
	URL=https://xcb.freedesktop.org/dist/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure $XORG_CONFIG
	make install
}
