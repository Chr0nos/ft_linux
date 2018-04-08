build() {
    VERSION="0.8.7.3"
    EXT="bz2"
    URL="http://archive.xfce.org/src/apps/$PKG/0.8/$PKG-$VERSION.tar.$EXT"
    build_generic
    cleanup
}