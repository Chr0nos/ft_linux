build() {
	VERSION="3.2.0"
	URL="http://archive.xfce.org/src/xfce/$PKG/3.2/$PKG-$VERSION.tar.bz2"
	prepair $PKG $VERSION bz2 $URL
	sed -i 's/\xd6/\xc3\x96/' gtk-3.0/xfce_style_types.h &&
		./configure --prefix=/usr --enable-gtk3              &&
		compile $PKG-$VERSION && make install && cleanup
}
