# depends: libuv

build() {
	PKG="cmake"
	VERSION="3.10.2"
	URL="https://cmake.org/files/v3.10/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION
	sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&

	./bootstrap --prefix=/usr        \
				--system-libs        \
				--mandir=/share/man  \
				--no-system-jsoncpp  \
				--no-system-librhash \
				--docdir=/share/doc/$PKG-$VERSION &&
	compile $PKG-$VERSION
	make install
}
