source $EBUILDS/xorg.sh

build() {
	PKG=libxcb
	VERSION=1.13
	URL=https://xcb.freedesktop.org/dist/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION
	sed -i "s/pthread-stubs//" configure &&
	./configure $XORG_CONFIG      \
				--without-doxygen \
				--docdir='${datadir}'/doc/$PKG-$VERSION
	compile $PKG-$VERSION
	make install
}
