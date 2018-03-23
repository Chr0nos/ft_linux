build() {
	PKG="libglade"
	VERSION="2.6.4"
	URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/2.6/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	sed -i '/DG_DISABLE_DEPRECATED/d' glade/Makefile.in &&
	./configure --prefix=/usr --disable-static &&
		compile $PKG-$VERSION
	cleanup $PKG $VERSION
}
