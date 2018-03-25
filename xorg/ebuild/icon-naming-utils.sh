build() {
	VERSION="0.8.90"
	URL="Shttp://tango.freedesktop.org/releases/$PKG-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && cleanup
}
