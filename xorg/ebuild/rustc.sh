build() {
	VERSION="1.25.0"
	URL="https://static.rust-lang.org/dist/rustc-$VERSION-src.tar.gz"
	pull $PKG gz $VERSION $URL
	unpack $PKG-$VERSION-src gz $PKG-$VERSION.tar.gz
	export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
	cat <<EOF > config.toml
# see config.toml.example for more possible options
[llvm]
targets = "X86"

[build]
# install cargo as well as rust
extended = true

[install]
prefix = "/usr"
docdir = "share/doc/rustc-1.25.0"

[rust]
channel = "stable"
rpath = false
EOF
	./x.py build
	./x.py install
	cleanup
}
