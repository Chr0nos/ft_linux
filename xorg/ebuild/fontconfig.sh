build() {
	PKG=fontconfig
	VERSION=2.13.0
	URL=https://www.freedesktop.org/software/$PKG/release/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION
	rm -vf src/fcobjshash.h
	./configure $XORG_CONFIG --docdir=/usr/share/doc/$PKG-$VERSION
	compile $PKG-$VERSION
	make install
}
