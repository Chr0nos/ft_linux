build() {
	PKG="xkeyboard-config"
	VERSION="2.23.1"
	URL="https://www.x.org/pub/individual/data/$PKG/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure $XORG_CONFIG --with-xkb-rules-symlink=xorg &&
		compile $PKG-$VERSION && make install
}
