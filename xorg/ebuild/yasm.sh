build() {
	VERSION="1.3.0"
	URL="http://www.tortall.net/projects/$PKG/releases/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	sed -i 's#) ytasm.*#)#' Makefile.in
	./configure --prefix=/usr && compile $PKG-$VERSION && make install
	cleanup
}
