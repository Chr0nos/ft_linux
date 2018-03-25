build() {
	VERSION="2.54.1"
	URL="http://ftp.gnome.org/pub/gnome/sources/glibmm/2.54/glibmm-2.54.1.tar.xz"
	prepair $PKG $VERSION xz $URL
	sed -e '/^libdocdir =/ s/$(book_name)/glibmm-2.54.1/' \
		-i docs/Makefile.in
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && \
		cleanup
}
