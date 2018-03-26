build() {
	VERSION="0.6.12"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/0.6/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr --disable-static && compile $PKG-$VERSION &&
		make install && cleanup
}
