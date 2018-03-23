build() {
	PKG=freetype
	VERSION=2.9
	URL=https://downloads.sourceforge.net/$PKG/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION
	sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg
	sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
		-i include/freetype/config/ftoption.h  &&
	./configure --prefix=$XORG_PREFIX --disable-static
	compile $PKG-$VERSION
	make install
}
