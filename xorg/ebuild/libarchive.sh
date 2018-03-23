build() {
	PKG="libarchive"
	VERSION="3.3.2"
	URL="http://www.libarchive.org/downloads/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	./configure --prefix=/usr --disable-static && compile $PKG-$VERSION
	make install
}
