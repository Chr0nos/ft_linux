build() {
	VERSION="1.12.2"
	URL="https://www.cairographics.org/releases/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	sed -e '/^libdocdir =/ s/$(book_name)/$PKG-$VERSION/' \
		-i docs/Makefile.in
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && \
		cleanup
}
