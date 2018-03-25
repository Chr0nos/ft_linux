build() {
	VERSION="2.24.32"
	URL="http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	sed -e 's#l \(gtk-.*\).sgml#& -o \1#' \
		-i docs/{faq,tutorial}/Makefile.in      &&
	./configure --prefix=/usr --sysconfdir=/etc
	compile $PKG-$VERSION
	make install
	cleanup
}
