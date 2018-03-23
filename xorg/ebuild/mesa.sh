# depends:
# xorg libs
# libdrm
# python2
# marko

build() {
	PKG=mesa
	VERSION=17.3.5
	URL=https://mesa.freedesktop.org/archive/$PKG-$VERSION.tar.xz
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz

}
