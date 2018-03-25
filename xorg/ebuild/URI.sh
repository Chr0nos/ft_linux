build() {
	VERSION="1.73"
	URL="https://www.cpan.org/authors/id/E/ET/ETHER/URI-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	perl Makefile.PL && compile $PKG-$VERSION && make install && cleanup
}
