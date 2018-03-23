build() {
	PKG="Mako"
	VERSION="1.0.4"
	URL="https://files.pythonhosted.org/packages/source/M/$PKG/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	python setup.py install --optimize=1
	if [ -l "/usr/bin/python3" ]; then
		sed -i "s:mako-render:&3:g" setup.py
		python3 setup.py install --optimize=1
	fi
}
