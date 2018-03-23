subbuild() {
	PKG=$1
	VERSION=$2
	EXT=$3
	URL=$4/$PKG-$VERSION.tar.$EXT
	pull $PKG $EXT $VERSION $URL
	unpack $PKG-$VERSION $EXT

	case $PKG in
		luit-[0-9]* )
			sed -i -e "/D_XOPEN/s/5/6/" configure
	 	;;
	esac
	./configure $XORG_CONFIG && compile $PKG-$VERSION && make install
	if [ $? != 0 ]; then
		echo "errror: failed to build/configure/install $PKG-$VERSION"
		exit 1
	fi
	cleanup $PKG $VERSION
}

build() {
	ROOTURL="https://www.x.org/pub/individual/app"

	subbuild iceauth 1.0.8 bz2 $ROOTURL
	subbuild luit 1.1.1 bz2 $ROOTURL
	subbuild mkfontdir 1.0.7 bz2 $ROOTURL
	subbuild mkfontscale 1.1.3 bz2 $ROOTURL
	subbuild sessreg 1.1.1 bz2 $ROOTURL
	subbuild setxkbmap 1.3.1 bz2 $ROOTURL
	subbuild smproxy 1.0.6 bz2 $ROOTURL
	subbuild x11perf 1.6.0 bz2 $ROOTURL
	subbuild xauth 1.0.10 bz2 $ROOTURL
	subbuild xbacklight 1.2.2 bz2 $ROOTURL
	subbuild xcmsdb 1.0.5 bz2 $ROOTURL
	subbuild xcursorgen 1.0.6 bz2 $ROOTURL
	subbuild xdpyinfo 1.3.2 bz2 $ROOTURL
	subbuild xdriinfo 1.0.6 bz2 $ROOTURL
	subbuild xev 1.2.2 bz2 $ROOTURL
	subbuild xgamma 1.0.6 bz2 $ROOTURL
	subbuild xhost 1.0.7 bz2 $ROOTURL
	subbuild xinput 1.6.2 bz2 $ROOTURL
	subbuild xkbcomp 1.4.1 bz2 $ROOTURL
	subbuild xkbevd 1.1.4 bz2 $ROOTURL
	subbuild xkbutils 1.0.4 bz2 $ROOTURL
	subbuild xkill 1.0.5 bz2 $ROOTURL
	subbuild xlsatoms 1.1.2 bz2 $ROOTURL
	subbuild xlsclients 1.1.4 bz2 $ROOTURL
	subbuild xmessage 1.0.5 bz2 $ROOTURL
	subbuild xmodmap 1.0.9 bz2 $ROOTURL
	subbuild xpr 1.0.5 bz2 $ROOTURL
	subbuild xprop 1.2.3 bz2 $ROOTURL
	subbuild xrandr 1.5.0 bz2 $ROOTURL
	subbuild xrdb 1.1.1 bz2 $ROOTURL
	subbuild xrefresh 1.0.6 bz2 $ROOTURL
	subbuild xset 1.2.4 bz2 $ROOTURL
	subbuild xsetroot 1.1.2 bz2 $ROOTURL
	subbuild xvinfo 1.1.3 bz2 $ROOTURL
	subbuild xwd 1.0.7 bz2 $ROOTURL
	subbuild xwininfo 1.1.4 bz2 $ROOTURL
	subbuild xwud 1.0.5 bz2 $ROOTURL
}
