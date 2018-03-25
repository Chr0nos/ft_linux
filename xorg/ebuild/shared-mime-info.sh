build() {
	VERSION="1.9"
	URL="https://people.freedesktop.org/~hadess/shared-mime-info-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr && compile $PKG-$VERSION 1 && make install
	cleanup
}
