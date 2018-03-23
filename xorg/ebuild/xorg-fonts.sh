subbuild() {
	PKG="$1"
	VERSION="$2"
	EXT="$3"
	URL="$4/$PKG-$VERSION.tar.$EXT"
	pull $PKG $EXT $VERSION $URL
	unpack $PKG-$VERSION $EXT
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install
	if [ $? != 0]; then
		echo "error: failed to install $PKG-$VERSION"
		exit 1
	fi
	cleanup $PKG $VERSION
}

build() {
	ROOTURL="https://www.x.org/pub/individual/font"
	subbuild font-util 1.3.1 bz2 $ROOTURL
	subbuild encodings 1.0.4 bz2 $ROOTURL
	subbuild font-alias 1.0.3 bz2 $ROOTURL
	subbuild font-adobe-utopia-type1 1.0.4 bz2 $ROOTURL
	subbuild font-bh-ttf 1.0.3 bz2 $ROOTURL
	subbuild font-bh-type1 1.0.3 bz2 $ROOTURL
	subbuild font-ibm-type1 1.0.3 bz2 $ROOTURL
	subbuild font-misc-ethiopic 1.0.3 bz2 $ROOTURL
	subbuild font-xfree86-type1 1.0.4 bz2 $ROOTURL
	install -v -d -m755 /usr/share/fonts                               &&
	ln -svfn $XORG_PREFIX/share/fonts/X11/OTF /usr/share/fonts/X11-OTF &&
	ln -svfn $XORG_PREFIX/share/fonts/X11/TTF /usr/share/fonts/X11-TTF
}
