build() {
	VERSION="2.40.1"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.40/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	sed -e '/^libdocdir =/ s/$(book_name)/$PKG-$VERSION/' \
		-i docs/Makefile.in
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && \
		cleanup
}
