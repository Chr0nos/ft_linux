build() {
	VERSION="4.0.9"
	URL="http://download.osgeo.org/libtiff/tiff-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack tiff-$VERSION gz $PKG-$VERSION.tar.gz
	mkdir -p libtiff-build &&
	cd       libtiff-build &&

	cmake -DCMAKE_INSTALL_DOCDIR=/usr/share/doc/libtiff-$VERSION \
		-DCMAKE_INSTALL_PREFIX=/usr -G Ninja .. &&
	ninja
	ninja install
	cleanup 
}
