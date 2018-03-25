build() {
	VERSION="1.0.9"
	URL="https://www.x.org/pub/individual/app/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	sed -i -e '/^rcdir =/s,^\(rcdir = \).*,\1/etc/X11/app-defaults,' src/Makefile.in
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install
	cleanup
}
