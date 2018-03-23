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
	GLL_DRV="i915,r600,nouveau,radeonsi,svga,swrast"
	./configure CFLAGS='-O2' CXXFLAGS='-O2' LDFLAGS=-lLLVM \
			--prefix=$XORG_PREFIX              \
			--sysconfdir=/etc                  \
			--enable-texture-float             \
			--enable-osmesa                    \
			--enable-xa                        \
			--enable-glx-tls                   \
			--with-platforms="drm,x11,wayland" \
			--with-gallium-drivers=$GLL_DRV
	compile $PKG-$VERSION
	make install
	unset GLL_DRV
}
