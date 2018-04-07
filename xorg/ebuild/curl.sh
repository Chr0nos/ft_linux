build() {
	VERSION="7.60.0-20180407"
	URL="https://curl.haxx.se/snapshoots/curl-$VERSION.tar.xz"
	prepair $PKG $VERSION xz $URL
	./configure --prefix=/usr                           \
				--disable-static                        \
				--enable-threaded-resolver              \
				--with-ca-path=/etc/ssl/certs &&
		compile $PKG-$VERSION && make install
	rm -rf docs/examples/.deps &&
	find docs \( -name Makefile\* \
				-o -name \*.1       \
				-o -name \*.3 \)    \
				-exec rm {} \;      &&

	install -v -d -m755 /usr/share/doc/curl-$VERSION &&
	cp -v -R docs/*     /usr/share/doc/curl-$VERSION
}
