build() {
	VERSION="60.2"
	URL="http://download.icu-project.org/files/icu4c/60.2/icu4c-60_2-src.tgz"
	pull $PKG tgz $VERSION $URL
	unpack icu4c-60_2-src tgz icu4c-60_2-src.tgz
	./configure --prefix=/usr && compile $PKG-$VERSION && make install
	cleanup
}
