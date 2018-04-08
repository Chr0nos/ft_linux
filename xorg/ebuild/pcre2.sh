build() {
    VERSION="10.30"
    EXT="bz2"
    URL="https://downloads.sourceforge.net/pcre/$PKG-$VERSION.tar.$EXT"
    prepair $PKG $VERSOIN $EXT $URL
    ./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-$VERSION \
            --enable-unicode                    \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static                    &&
        compile $PKG &&
        make install &&
        cleanup
}