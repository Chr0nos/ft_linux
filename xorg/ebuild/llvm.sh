add_clang() {
	pull clang xz $VERSION http://llvm.org/releases/$VERSION/cfe-$VERSION.src.tar.xz
	tar -xf $SOURCES/clang-$VERSION.tar.xz -C tools
	mv tools/cfe-$VERSION.src tools/clang
}

build() {
	PKG="llvm"
	VERSION="6.0.0"
	URL="http://llvm.org/releases/$VERSION/$PKG-$VERSION.src.tar.xz"
	pull $PKG xz $VERSION $URL
	unpack $PKG-$VERSION.src xz $PKG-$VERSION.tar.xz
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
	compile $PKG-$VERSION 2
	make install
	# clang documentation
	install -v -m644 tools/clang/docs/man/* /usr/share/man/man1
	install -v -d -m755 /usr/share/doc/llvm-$VERSION/clang-html
	cp -Rv tools/clang/docs/html/* /usr/share/doc/llvm-$VERSION/clang-html
	cleanup $PKG $VERSION
}
