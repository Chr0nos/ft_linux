build() {
	VERSION="331"
	URL="http://invisible-mirror.net/archives/xterm/xterm-$VERSION.tgz"
	prepair $PKG $VERSION tgz $URL

	sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap &&
		printf '\tkbs=\\177,\n' >> terminfo &&
		TERMINFO=/usr/share/terminfo \
		./configure $XORG_CONFIG --with-app-defaults=/etc/X11/app-defaults &&
		compile $PKG-$VERSION && make install && cleanup
	cat >> /etc/X11/app-defaults/XTerm << "EOF"
*VT100*locale: true
*VT100*faceName: Monospace
*VT100*faceSize: 10
*backarrowKeyIsErase: true
*ptyInitialErase: true
EOF

}
