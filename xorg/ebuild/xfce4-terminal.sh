build() {
    VERSION="0.8.7.3"
    URL="http://archive.xfce.org/src/apps/$PKG/0.8/$PKG-$VERSION.tar.bz2"
    prepair $PKG $VERSION bz2 $URL
    build_generic bz2
    cleanup
}