build_python2() {
    mkdir python2 &&
        pushd python2 &&
        ../configure --prefix=/usr --with-python=/usr/bin/python &&
        compile $PKG &&
        popd
    cd ..
}

build_python3() {
    mkdir python3 &&
        pushd python3 &&
        ../configure --prefix=/usr --with-python=/usr/bin/python3 &&
        compile $PKG &&
        popd
    cd ..
}

build() {
    VERSION="3.28.2"
    EXT="xz"
    URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/3.28/$PKG-$VERSION.tar.$EXT"
    prepair $PKG $VERSION $EXT $URL
    build_python2
    build_python3
    make -C python2 install
    make -C python3 install
    cleanup
}