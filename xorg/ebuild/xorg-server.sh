build() {
	PKG="xorg-server"
	VERSION="1.19.6"
	URL="https://www.x.org/pub/individual/xserver/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure $XORG_CONFIG				\
			--enable-glamor					\
			--enable-suid-wrapper			\
			--with-xkb-output=/var/lib/xkb
	compile $PKG-$VERSION
	make install
	mkdir -pv /etc/X11/xorg.conf.d
}
