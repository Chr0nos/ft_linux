build() {
	VERSION="0.4.4"
	URL="https://www.x.org/archive//individual/driver/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install && cleanup
}
