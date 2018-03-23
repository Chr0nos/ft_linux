build() {
	PKG="Beaker"
	VERSION="1.9.0"
	URL="https://files.pythonhosted.org/packages/source/B/$PKG/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	python setup.py install --optimize=1
	if [ -l /usr/bin/python3 ]; then
		python3 setup.py install --optimize=1
	fi
	cleanup $PKG $VERSION
}
