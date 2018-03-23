build() {
	PKG="libuv"
	VERSION="1.19.2"
	URL="https://dist.libuv.org/dist/v$VERSION/$PKG-v$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION
	sh autogen.sh
	./configure --prefix=/usr --disable-static
	compile $PKG-$VERSION
	make install
}
