source $EBUILDS/xorg.sh

build() {
	PKG=util-macros
	VERSION=1.19.2
	URL=https://www.x.org/pub/individual/util/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure --prefix=/usr
	compile $PKG
	make install
}
