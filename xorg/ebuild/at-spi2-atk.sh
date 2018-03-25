build() {
	VERSION="2.26.1"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.26/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSIOn xz $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && cleanup
}
