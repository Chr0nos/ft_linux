build() {
	PKG="libepoxy"
	VERSION="1.5.0"
	URL="https://github.com/anholt/$PKG/releases/download/$VERSION/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr
	compile $PKG-$VERSION
	make install
	cleanup $PKG $VERSION
}
