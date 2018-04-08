build() {
	VERSION="3.28"
	URL="https://ftp.gnome.org/pub/GNOME/sources/adwaita-icon-theme/3.28/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && cleanup
}
