build() {
	PKG="make-ca"
	VERSION="0.7"
	URL="https://github.com/djlucas/$PKG/archive/v$VERSION/$PKG-$VERSION.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION gz
	install -vdm755 /etc/ssl/local &&
	wget http://www.cacert.org/certs/root.crt &&
	wget http://www.cacert.org/certs/class3.crt &&
	openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
			-addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
			> /etc/ssl/local/CAcert_Class_1_root.pem &&
	openssl x509 -in class3.crt -text -fingerprint -setalias "CAcert Class 3 root" \
			-addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
			> /etc/ssl/local/CAcert_Class_3_root.pem
	make install
	/usr/sbin/make-ca -g
}
