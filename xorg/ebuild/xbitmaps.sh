build() {
	PKG="xbitmaps"
	VERSION="1.1.2"
	URL="https://www.x.org/pub/individual/data/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure $XORG_CONFIG
	make install
}
