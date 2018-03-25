build() {
	VERSION="2.24"
	URL="https://www.cpan.org/authors/id/G/GR/GRANTM/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	perl Makefile.PL && compile $PKG-$VERSION && make install && cleanup
}
