build() {
	VERSION="1.0.2n"
	URL="https://openssl.org/source/openssl-$VERSION.tar.gz"
	prepair $PKG $VERSIOn gz $URL
	/config --prefix=/usr --openssldir=/etc/ssl --libdir=lib/openssl-1.0 \
		shared zlib-dynamic && make depend && compile $PKG-$VERSION 1 &&
		make INSTALL_PREFIX=$PWD/Dest install_sw
	rm -rf /usr/lib/openssl-1.0                                   &&
	install -vdm755                   /usr/lib/openssl-1.0        &&
	cp -Rv Dest/usr/lib/openssl-1.0/* /usr/lib/openssl-1.0        &&

	mv -v  /usr/lib/openssl-1.0/lib{crypto,ssl}.so.1.0.0 /usr/lib &&
	ln -sv ../libssl.so.1.0.0         /usr/lib/openssl-1.0        &&
	ln -sv ../libcrypto.so.1.0.0      /usr/lib/openssl-1.0        &&

	install -vdm755                   /usr/include/openssl-1.0    &&
	cp -Rv Dest/usr/include/openssl   /usr/include/openssl-1.0    &&

	sed 's@/include$@/include/openssl-1.0@' -i /usr/lib/openssl-1.0/pkgconfig/*.pc
}
