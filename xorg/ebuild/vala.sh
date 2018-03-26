build() {
	VERSION="0.38.8"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/0.38/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	sed -i '102d; 108,124d; 126,127d'  configure.ac &&
	sed -i '/valadoc/d' Makefile.am                 &&
	ACLOCAL= autoreconf -fiv                        &&
	./configure --prefix=/usr                       &&
	compile $PKG-$VERSION && make install && cleanup
}
