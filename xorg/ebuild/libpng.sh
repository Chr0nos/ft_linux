build() {
	PKG="libpng"
	VERSION="1.6.34"
	URL="https://downloads.sourceforge.net/libpng/libpng-1.6.34.tar.xz"
	PATCH="libpng-$VERSION-apng.patch.gz"
	pull $PKG xz $VERSION $URL
	wget https://downloads.sourceforge.net/sourceforge/libpng-apng/$PATCH --no-check-certificate
	if [ $? != 0 ]; then
		echo "error: failed to get patch $PATCH for $PKG-$VERSION"
		exit 1
	fi
	gzip -cd $PATCH | patch -p1
	LIBS=-lpthread ./configure --prefix=/usr --disable-static &&
	compile $PKG-$VERSION
	make install
	mkdir -v /usr/share/doc/$PKG-$VERSION &&
	cp -v README libpng-manual.txt /usr/share/doc/$PKG-$VERSION
}
