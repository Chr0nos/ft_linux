build() {
    VERSION="0.52.0"
    EXT="xz"
    URL="http://ftp.gnome.org/pub/gnome/sources/$PKG/0.52/$PKG-$VERSION.tar.$EXT"
    CFG="--sysconfdir=/etc --disable-static --enable-introspection"
    build_generic
}