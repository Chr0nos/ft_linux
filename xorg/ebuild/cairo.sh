build() {
	VERSION="1.14.12"
	URL="https://www.cairographics.org/releases/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	./configure --prefix=/usr    \
				--disable-static \
				--enable-tee && compile $PKG-$VERSION && make install
	cleanup
}
