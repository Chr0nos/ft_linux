build() {
	VERSION="1.11.0"
	URL="https://pypi.io/packages/source/s/$PKG/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	python2 setup.py build
	python2 setup.py install --optimize=1
	python3 setup.py build
	python3 setup.py install --optimize=1
	cleanup
}
