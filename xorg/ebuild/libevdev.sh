build() {
	VERSION="1.5.9"
	URL="https://www.freedesktop.org/software/$PKG/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install
	cleanup
}
