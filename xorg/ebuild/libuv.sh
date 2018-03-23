build() {
	PKG="libuv"
	VERSION="1.19.2"
	URL="https://dist.libuv.org/dist/v$VERSION/$PKG-v$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-v$VERSION gz $PKG-$VERSION.tar.gz
	sh autogen.sh
	./configure --prefix=/usr --disable-static
	compile $PKG-$VERSION
	make install
	cleanup $PKG $VERSION
}
