build_python2() {
    /usr/bin/python2 setup.py build && python2 setup.py install --optimize=1
}

build_python3() {
    /usr/bin/python3 setup.py build && python3 setup.py install --optimize=1
}

build() {
    VERSION="1.16.3"
    EXT="gz"
    URL="https://github.com/pygobject/pycairo/releases/download/v1.16.3/pycairo-$VERSION.tar.$EXT"
    prepair $PKG $VERSION $EXT $URL
    build_python2 && build_python3 && cleanup
}