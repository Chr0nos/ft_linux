# build() {
# 	VERSION="1.0.2o"
# 	URL="https://openssl.org/source/openssl-$VERSION.tar.gz"
# 	prepair $PKG $VERSION gz $URL
# 	wget --no-check-certificate http://www.linuxfromscratch.org/patches/blfs/svn/openssl-1.0.2o-compat_versioned_symbols-1.patch
# 	patch -Np1 -i ../openssl-1.0.2o-compat_versioned_symbols-1.patch
# 	if [ $? != 0]; then
# 		echo "failed to patch $PKG"
# 		exit 1
# 	fi
# 	./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib/openssl-1.0 \
# 		shared zlib-dynamic &&
# 		make depend &&
# 		compile $PKG-$VERSION 1 &&
# 		make INSTALL_PREFIX=$PWD/Dest install_sw

# 	rm -rf /usr/lib/openssl-1.0                                   &&
# 	install -vdm755                   /usr/lib/openssl-1.0        &&
# 	cp -Rv Dest/usr/lib/openssl-1.0/* /usr/lib/openssl-1.0        &&

# 	mv -v  /usr/lib/openssl-1.0/lib{crypto,ssl}.so.1.0.0 /usr/lib &&
# 	ln -sv ../libssl.so.1.0.0         /usr/lib/openssl-1.0        &&
# 	ln -sv ../libcrypto.so.1.0.0      /usr/lib/openssl-1.0        &&

# 	install -vdm755                   /usr/include/openssl-1.0    &&
# 	cp -Rv Dest/usr/include/openssl   /usr/include/openssl-1.0    &&

# 	sed 's@/include$@/include/openssl-1.0@' -i /usr/lib/openssl-1.0/pkgconfig/*.pc
# 	make install
# 	cleanup
# }

build() {
	VERISON="1.1.0h"
	URL="https://www.openssl.org/source/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic && compile $PKG 1
	if [ $? != 0]; then
		echo "failed to prepair $PKG"
		exit 1
	fi
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
	make MANSUFFIX=ssl install
	mv -v /usr/share/doc/openssl /usr/share/doc/$PKG-$VERSION
	cp -vfr doc/* /usr/share/doc/$PKG-$VERSION
}