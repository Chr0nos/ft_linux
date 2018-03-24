build() {
	VERSION="2.13.03"
	URL="http://www.nasm.us/pub/$PKG/releasebuilds/$VERSION/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr && compile $PKG-$VERSION && make install
	cleanup
}
