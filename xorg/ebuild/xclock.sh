build() {
	VERSION="1.0.7"
	URL="https://www.x.org/pub/individual/app/xclock-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install && cleanup
}
