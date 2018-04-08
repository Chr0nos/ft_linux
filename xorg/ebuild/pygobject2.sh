build() {
    VERSION="2.28.7"
    EXT="xz"
    URL="http://ftp.gnome.org/pub/gnome/sources/pygobject/2.28/pygobject-$VERSION.tar.$EXT"
    prepair $PKG $VERSION $EXT $URL
    make install && cleanup
}