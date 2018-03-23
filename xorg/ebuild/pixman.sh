build() {
	PKG="pixman"
	VERSION="0.34.0"
	URL="https://www.cairographics.org/releases/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	./configure --prefix=/usr --disable-static
	compile $PKG-$VERSION
	make install
}
