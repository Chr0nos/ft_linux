add_clang() {
	pull clang xz 5.0.1 http://llvm.org/releases/5.0.1/cfe-5.0.1.src.tar.xz
	tar -xf $SOURCES/cfe-5.0.1.tar.xz -C tools
	mv tools/cfe-5.0.1.src tools/clang
}

build() {
	PKG="llvm"
	VERSION="5.0.1"
	URL="http://llvm.org/releases/$VERSION/$PKG-$VERSION.src.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION xz
	add_clang
	mkdir -v build
	cd build
	CC=gcc CXX=g++                                \
			cmake -DCMAKE_INSTALL_PREFIX=/usr     \
			-DLLVM_ENABLE_FFI=ON                  \
			-DCMAKE_BUILD_TYPE=Release            \
			-DLLVM_BUILD_LLVM_DYLIB=ON            \
			-DLLVM_TARGETS_TO_BUILD="host;AMDGPU" \
			-Wno-dev ..
	compile $PKG-$VERSION
	make install
	# clang documentation
	install -v -m644 tools/clang/docs/man/* /usr/share/man/man1
	install -v -d -m755 /usr/share/doc/llvm-5.0.1/clang-html
	cp -Rv tools/clang/docs/html/* /usr/share/doc/llvm-5.0.1/clang-html
}
