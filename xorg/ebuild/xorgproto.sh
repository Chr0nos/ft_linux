source $EBUILDS/xorg.sh

build() {
	PKG=xorgproto
	VERSION=2018.4
	URL=https://xorg.freedesktop.org/archive/individual/proto/$PKG-$VERSION.tar.bz2
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	mkdir build
	cd build
	meson --prefix=$XORG_PREFIX .. && ninja
	if [ $? != 0 ]; then
		echo "build has failed"
		exit 1
	fi
	ninja install
	install -vdm 755 $XORG_PREFIX/share/doc/$PKG-$VERSION &&
	install -vm 644 ../[^m]*.txt ../PM_spec $XORG_PREFIX/share/doc/$PKG-$VERSION
}
