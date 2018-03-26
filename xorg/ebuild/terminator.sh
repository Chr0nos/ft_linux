build() {
	VERSION="1.91"
	URL="https://launchpad.net/terminator/gtk3/1.91/+download/terminator-1.91.tar.gz"
	prepair $PKG $VERSION gz $URL
	./configure --prefix=/usr && compile $PKG-$VERSION && make install && cleanup
}
