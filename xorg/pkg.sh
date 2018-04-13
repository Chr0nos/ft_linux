export SOURCES="/dev/shm"
export SRCS="/tmp"
export EBUILDS="./ebuild"
export ROOT=$(pwd)
export XORG_PREFIX="/usr"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

unpack() {
	UNPACK_PKG="$1"
	FILE=$UNPACK_PKG.tar.$2
	TARGET=$FILE
	cd $SRCS
	if [ -n "$3" ]; then
		TARGET=$SOURCES/$3
	else
		TARGET=$SOURCES/$FILE
	fi

	if [ ! -f $TARGET ]; then
		echo "unpack error: unable to find $TARGET"
		exit 1
	fi

	if [ -d $UNPACK_PKG ]; then
		echo "unpack cleaning previous installation"
		rm -r $UNPACK_PKG
	fi
	echo "Extracting $UNPACK_PKG"
	tar -xf $TARGET
	if [ ! -d $UNPACK_PKG ]; then
		echo "failed to unpack source, check if $UNPACK_PKG exists"
		exit 1
	fi
	cd $UNPACK_PKG
	echo "unpack of $UNPACK_PKG ok"
}

# usage: compile [PKG] <threads to use>
compile() {
	echo "Compiling $PKG-$VERSION"
	make -j$2
	if [ $? != 0 ]; then
		echo "compilation failed for $PKG-$VERSION"
		exit 1
	fi
}

# usage : build_generic
build_generic() {
	echo "Building $PKG"
	prepair $PKG $VERSION $EXT $URL
	if [ -f configure ]; then
		echo "Configuring $PKG from $(pwd)"
		./configure --prefix=/usr $CFG $1
		if [ $? != 0 ]; then
			echo "Error: failed to configure $PKG"
			exit 1
		fi
	fi
	compile $PKG
	echo "Installing"
	make $2 install
	echo "$PKG done."
	if [ $? == 0 ]; then
		cleanup
	fi
}

lpull() {
	pull $PKG $EXT $VERSION $URL
}

lprepair() {
	prepair $PKG $VERSION $EXT $URL
}

# usge: pull [PKG] [EXT] [VERSION] [URL]
pull() {
	PULLPKG="$1"
	EXT="$2"
	FILE="$PULLPKG-$3.tar.$EXT"
	if [ -f $SOURCES/$FILE ]; then
		echo "$PULLPKG source already here."
		return
	fi
	URL="$4"
	echo "getting $PULLPKG from $URL"
	wget $URL -O $SOURCES/$FILE --no-check-certificate
	if [ $? != 0 ]; then
		echo "error: failed to get $PULLPKG at $URL"
		exit 1
	fi
	echo "Successfully retrived $PULLPKG-$VERSION"
}

# usage: prepair <PKG> <VERSION> <EXT> <URL>
prepair() {
	pull $1 $3 $2 $4 && unpack $1-$2 $3
}

cleanup() {
	if [ -d $SRCS/$PKG-$VERSION ]; then
		echo "cleaning traces of $PKG-$VERSION"
		rm -rf $SRCS/$PKG-$VERSION
	else
		echo "nothing to clean for $PKG-$VERSION"
	fi
}

build_pkg() {
	PKG="$1"
	FILE="$EBUILDS/$PKG.sh"
	cd $ROOT
	if [ ! -f $FILE ]; then
		echo "no such package $PKG"
		return 1
	fi
	source $FILE
	build
	echo "$PKG done."
}

build_pkg $@
