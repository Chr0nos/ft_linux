build() {
    VERSION="git"
    cd $SRCS
    git clone https://github.com/fish-shell/fish-shell.git
    cd $SRCS/fish-shell
    mkdir -b build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr
    compile $PKG
    make install
    cd $SRCS
    rm -rf fish-shell
}