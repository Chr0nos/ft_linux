# http://fr.linuxfromscratch.org/view/blfs systemd svn/x/x7lib.html

subbuild() {
	PKG="$1"
	VERSION="$2"
	URL="$3/$PKG-$VERSION.tar.bz2"
	echo "building $PKG-$VERSION"
	pull $PKG bz2 $VERSION $URL
	unpack $PKG $VERSION
	case $PKG in
		libICE*)
			./configure $XORG_CONFIG ICE_LIBS= lpthread
		;;
		libXfont)
			./configure $XORG_CONFIG   disable devel docs
		;;
		libXt)
			./configure $XORG_CONFIG   with appdefaultdir=/etc/X11/app defaults
		;;
		*)
			./configure $XORG_CONFIG
		;;
	esac
	compile $PKG $VERSION
	make install
	echo "$PKG done."
}

build() {
	PKG="xorg-libs"
	VERSION="1.0"
	ROOTURL="https://www.x.org/archive//individual/lib"
	subbuild xtrans 1.3.5 $ROOTURL
	subbuild libX11 1.6.5 $ROOTURL
	subbuild libXext 1.3.3 $ROOTURL
	subbuild libFS 1.0.7 $ROOTURL
	subbuild libICE 1.0.9 $ROOTURL
	subbuild libSM 1.2.2 $ROOTURL
	subbuild libXScrnSaver 1.2.2 $ROOTURL
	subbuild libXt 1.1.5 $ROOTURL
	subbuild libXmu 1.1.2 $ROOTURL
	subbuild libXpm 3.5.12 $ROOTURL
	subbuild libXaw 1.0.13 $ROOTURL
	subbuild libXfixes 5.0.3 $ROOTURL
	subbuild libXcomposite 0.4.4 $ROOTURL
	subbuild libXrender 0.9.10 $ROOTURL
	subbuild libXcursor 1.1.15 $ROOTURL
	subbuild libXdamage 1.1.4 $ROOTURL
	subbuild libfontenc 1.1.3 $ROOTURL
	subbuild libXfont2 2.0.3 $ROOTURL
	subbuild libXft 2.3.2 $ROOTURL
	subbuild libXi 1.7.9 $ROOTURL
	subbuild libXinerama 1.1.3 $ROOTURL
	subbuild libXrandr 1.5.1 $ROOTURL
	subbuild libXres 1.2.0 $ROOTURL
	subbuild libXtst 1.2.3 $ROOTURL
	subbuild libXv 1.0.11 $ROOTURL
	subbuild libXvMC 1.0.10 $ROOTURL
	subbuild libXxf86dga 1.1.4 $ROOTURL
	subbuild libXxf86vm 1.1.4 $ROOTURL
	subbuild libdmx 1.1.3 $ROOTURL
	subbuild libpciaccess 0.14 $ROOTURL
	subbuild libxkbfile 1.0.9 $ROOTURL
	subbuild libxshmfence 1.3 $ROOTURL
	echo "$PKG done."
}
