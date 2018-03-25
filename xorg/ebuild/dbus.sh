build() {
	VERSION="1.12.4"
	URL="https://dbus.freedesktop.org/releases/$PKG/$PKG-$VERSION.tar.gz"
	prepair $PKG $VERSION gz $URL
	./configure --prefix=/usr                        \
				--sysconfdir=/etc                    \
				--localstatedir=/var                 \
				--enable-user-session                \
				--disable-doxygen-docs               \
				--disable-xml-docs                   \
				--disable-static                     \
				--docdir=/usr/share/doc/$PKG-$VERSION \
				--with-console-auth-dir=/run/console \
				--with-system-pid-file=/run/$PKG/pid \
				--with-system-socket=/run/$PKG/system_bus_socket && \
			compile $PKG-$VERSION && make install && \
	mv -v /usr/lib/libdbus-1.so.* /lib && \
	ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so && \
	cleanup
	chown -v root:messagebus /usr/libexec/dbus-daemon-launch-helper
	chmod -v      4750       /usr/libexec/dbus-daemon-launch-helper
	systemctl daemon-reload
	systemctl start multi-user.target
}
