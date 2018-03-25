build() {
	VERSION="2.30.7"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.30/$PKG-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr \
				--disable-static \
				--program-suffix=-1 &&
			make GETTEXT_PACKAGE=libwnck-1 && make install && cleanup
}
