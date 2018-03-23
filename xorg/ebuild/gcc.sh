# ftp://ftp.uvsq.fr/pub/gcc/snapshots/8-20180318/gcc-8-20180318.tar.xz

build() {
	PKG="gcc"
	VERSION="7.3.0"
	URL="ftp://ftp.uvsq.fr/pub/$PKG/releases/$PKG-$VERSION/$PKG-$VERSION.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
		;;
	esac
	rm -fv /usr/lib/gcc
	mkdir -v build
	cd build
	SED=sed                               \
	../configure --prefix=/usr            \
		--enable-languages=c,c++ \
		--disable-multilib       \
		--disable-bootstrap      \
		--with-system-zlib
	if [ $? != 0 ]; then
		echo "error: failed to configure $PKG-$VERSION"
		exit 1
	fi
	compile $PKG-$VERSION 2
	ulimit -s 32768
	make -k check
	../contrib/test_summary
	unset SED
	make install
	ln -sv ../usr/bin/cpp /lib
	if [ -f /usr/bin/cc ]; then
		rm -fv /usr/bin/cc
	fi
	ln -sv gcc /usr/bin/cc
	install -v -dm755 /usr/lib/bfd-plugins
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/$VERSION/liblto_plugin.so \
		/usr/lib/bfd-plugins/
	echo 'int main(){ return (0); }' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	if [ $? != 0 ]; then
		echo "error: $PKG cannot create binaries"
		exit 1
	fi
	readelf -l a.out | grep ': /lib'
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
	grep -B4 '^ /usr/include' dummy.log
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
	grep "/lib.*/libc.so.6 " dummy.log
	grep found dummy.log
	rm -v dummy.c a.out dummy.log
	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	echo "$PKG done."
}
