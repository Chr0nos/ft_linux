build() {
	VERSION="1.4.0"
	URL="https://www.x.org/pub/individual/app/$PKG-$VERSIOn.tar.bz2"
	prepair $PKG $VERSION bz2 $URL

	# prevent start on virtual terminal 7
	sed -e '/$serverargs $vtarg/ s/serverargs/: #&/' \
		-i startx.cpp

	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install && cleanup
}
