build() {
	PKG="MarkupSafe"
	VERSION="1.0"
	URL="https://files.pythonhosted.org/packages/source/M/$PKG/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	python setup.py build
	python setup.py install --optimize=1
	if [ -l /usr/bin/python3 ]; then
		python3 setup.py build
		python3 setup.py install --optimize=1
	fi
}
