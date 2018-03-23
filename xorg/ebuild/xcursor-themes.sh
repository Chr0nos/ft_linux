build() {
	PKG="xcursor-themes"
	VERSION="1.0.5"
	URL=" https://www.x.org/pub/individual/data/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install
}
