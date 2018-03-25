build() {
	VERSION="2.4.0"
	URL="https://www.x.org/archive/individual/driver/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install && cleanup
}
