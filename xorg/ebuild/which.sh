build() {
	PKG="which"
	VERSION="2.21"
	URL="https://ftp.gnu.org/gnu/$PKG/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	./configure --prefix=/usr && compile $PKG-$VERSION $$ make install
	cleanup $PKG $VERSION
}
