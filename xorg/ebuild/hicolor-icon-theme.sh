build() {
	VERSION="0.17"
	URL="https://icon-theme.freedesktop.org/releases/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr && compile $PKG-$VERSIOn && make install && cleanup
}
