build() {
	PKG="libXau"
	VERSION="1.0.8"
	URL="https://www.x.org/pub/individual/lib/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure $XORG_CONFIG
	compile $PKG-$VERSION
	make install
}
