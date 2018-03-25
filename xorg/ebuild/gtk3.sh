build() {
	VERSION="3.22.28"
	URL="http://ftp.gnome.org/pub/gnome/sources/gtk+/3.22/gtk+-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack gtk+-$VERSION xz $PKG-$VERSION.tar.xz
	./configure --prefix=/usr             \
				--sysconfdir=/etc         \
				--enable-broadway-backend \
				--enable-x11-backend
		compile $PKG-$VERSION && make install
	if [ $? == 0 ]; then
		gtk-query-immodules-3.0 --update-cache
		glib-compile-schemas /usr/share/glib-2.0/schemas
		cleanup
	fi
}
