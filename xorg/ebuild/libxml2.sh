build() {
	PKG="libxml2"
	VERSION="2.9.8"
	URL="http://xmlsoft.org/sources/$PKG-$VERSION.tar.gz"
	PATCH="libxml2-2.9.8-python3_hack-1.patch"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	wget http://www.linuxfromscratch.org/patches/blfs/svn/$PATCH --no-check-certificate
	patch -Np1 -i $PATCH
	sed -i '/_PyVerify_fd/,+1d' python/types.c
	./configure --prefix=/usr    \
				--disable-static \
				--with-history   \
				--with-python=/usr/bin/python3 &&
			compile $PKG-$VERSION && make install
}
