build() {
	VERSION="1.1.5"
	URL="http://bitmath.org/code/$PKG/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure --prefix=/usr --disable-static && compile $PKG-$VERSION &&
		make install
	cleanup
}
