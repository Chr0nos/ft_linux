build() {
	VERSION="4.12.1"
	URL="http://archive.xfce.org/src/xfce/libxfce4util/4.12/libxfce4util-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && \
		cleanup
}
