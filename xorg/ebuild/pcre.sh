build() {
	PKG="pcre"
	VERSION="8.41"
	URL="https://downloads.sourceforge.net/$PKG/$PKG-$VERSION.tar.bz2"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG-$VERSION bz2
	./configure --prefix=/usr                         \
				--docdir=/usr/share/doc/$PKG-$VERSION \
				--enable-unicode-properties           \
				--enable-pcre16                       \
				--enable-pcre32                       \
				--enable-pcregrep-libz                \
				--enable-pcregrep-libbz2              \
				--enable-pcretest-libreadline         \
				--disable-static
	compile $PKG-$VERSION
	cleanup $PKG $VERSION
}
