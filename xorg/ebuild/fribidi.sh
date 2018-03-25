build() {
	VERSION="1.0.2"
	URL="https://github.com/$PKG/$PKG/releases/download/v$VERSION/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	meson --prefix=/usr && compile $PKG-$VERSION && make install
	cleanup
}
