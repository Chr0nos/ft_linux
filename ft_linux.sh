#!/bin/sh
source ./config.sh
################################ GENERIC PART ##################################

extract() {
	cd $SRCS
	echo "Extracting $1"
	if [ ! -f $SOURCES/$1 ]; then
		echo "Error: failed to find sources."
		exit 1
	fi
	tar -xf $SOURCES/$1
}

compile() {
	PKG=$1
	echo "Compiling $PKG"
	make -j$2
	if [ $? != 0 ]; then
		echo "compilation failed for $PKG"
		exit 1
	fi
}

# usage : build_generic PKG SOURCEFILE <options to configure> 
build_generic() {
	PKG=$1
	echo "Building $PKG"
	extract $2
	cd $PKG
	echo "Configuring"
	./configure --prefix=/tools $3
	if [ $? != 0 ]; then
		echo "Error: failed to configure $PKG"
		exit 1
	fi
	echo "Compiling"
	compile $PKG
	echo "Installing"
	make $4 install
	echo "$PKG done."
}

############################## END OF GENERIC PART #############################


# 3.1
get_sources() {
	mkdir -pv $LFS
	curl http://fr.linuxfromscratch.org/view/lfs-systemd-svn/wget-list -o wget-list
	if [ $? != 0 ]; then
		echo "error: failed to get sources, this cannot continue"
		exit 1
	fi
	mkdir -pv sources
	chmod -v a+wt sources
	wget --input-file=wget-list --continue --directory-prefix=sources/
	mkdir -pv $LFS/usr/src/sources
	cp -rv sources/* $SOURCES/
}

# 4.2
mk_tools() {
	mkdir -v $LFS/tools
	sudo ln -sv $LFS/tools /
	if [ ! -l /tools ]; then
		echo "error: you need to manualy create a link /tools to $LFS/tools"
		exit 1
	fi
}


# 4.4

# 5.4
build_binutils_step1() {
	cd $SRCS
	PKG=binutils-2.30
	tar -xf $SOURCES/$PKG.tar.xz
	cd $PKG
	mkdir -v build
	cd build
	../configure --prefix=/tools            \
		         --with-sysroot=$LFS        \
			     --with-lib-path=/tools/lib \
			     --target=$LFS_TGT          \
			     --disable-nls              \
			     --disable-werro
	compile $PKG
	case $(uname -m) in
  		x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
	esac
	make install
	cd ..
	rm -rf build
}

# 5.5
build_gcc_step1() {
	echo "prepairing gcc"
	PKG=gcc-7.3.0
	cd $SRCS
	if [ -d $PKG ]; then
		echo cleaning previous dir
		rm -rf $PKG
		echo clean done
	fi
	tar -xf $SOURCES/gcc-7.3.0.tar.xz
	cd gcc-7.3.0
	tar -xf $SOURCES/mpfr-4.0.1.tar.xz
	mv -v mpfr-4.0.1 mpfr
	tar -xf $SOURCES/gmp-6.1.2.tar.xz
	mv -v gmp-6.1.2 gmp
	tar -xf $SOURCES/mpc-1.1.0.tar.gz
	mv -v mpc-1.1.0 mpc

	# La commande suivante modifiera l'emplacement de l'éditeur de liens
	# dynamique par défaut de GCC pour utiliser celui installé dans /tools.
	# Elle supprime aussi /usr/include du chemin de recherche include de GCC
	for file in gcc/config/{linux,i386/linux{,64}}.h
	do
		echo $file
		cp -uv $file{,.orig}
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
			-e 's@/usr@/tools@g' $file.orig > $file
		echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
		touch $file.orig
	done

	echo "patching lib path"
	# fix lib64
	case $(uname -m) in
		x86_64)
    		sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
 		;;
	esac

	# compilation
	mkdir -v build
	cd build
	../configure                                       \
	    --target=$LFS_TGT                              \
		--prefix=/tools                                \
		--with-glibc-version=2.11                      \
		--with-sysroot=$LFS                            \
		--with-newlib                                  \
		--without-headers                              \
		--with-local-prefix=/tools                     \
		--with-native-system-header-dir=/tools/include \
		--disable-nls                                  \
		--disable-shared                               \
		--disable-multilib                             \
		--disable-decimal-float                        \
		--disable-threads                              \
		--disable-libatomic                            \
		--disable-libgomp                              \
		--disable-libmpx                               \
		--disable-libquadmath                          \
		--disable-libssp                               \
		--disable-libvtv                               \
		--disable-libstdcxx                            \
		--enable-languages=c,c++
	compile $PKG $MAXCORE
	make install
}

# 5.6
build_api_headers() {
	cd $SRCS
	echo "installing kernel sources"
	tar -xf $SOURCES/linux-4.15.7.tar.xz
	cd linux-4.15.7
	make mrproper
	make INSTALL_HDR_PATH=dest headers_install
	cp -rv dest/include/* /tools/include
	echo "done"
}

# 5.7 : glibc
build_glibc() {
	PKG=glibc-2.27
	echo "making $PKG"
	cd $SRCS
	tar -xf $SOURCES/$PKG.tar.xz
	cd $PKG
	mkdir -v build
	cd build
	../configure                           \
		--prefix=/tools                    \
		--host=$LFS_TGT                    \
		--build=$(../scripts/config.guess) \
		--enable-kernel=3.2                \
		--with-headers=/tools/include      \
		libc_cv_forced_unwind=yes          \
		libc_cv_c_cleanup=yes
	compile $PKG $MAXCORE
	make install

	# critical test ! do not skip ! i'm serious dude
	echo 'int main(){}' > dummy.c
	/tools/bin/$LFS_TGT-gcc dummy.c
	if [ ! -f a.out ]; then
		echo "failed to compile a.out, quit"
		exit 1
	fi
	readelf -l a.out | grep ': /tools'
	if [ $? != 0 ]; then
		echo "failed to read elf file, you are domed ($PKG)"
		exit 1
	fi
	rm -v dummy.c a.out
}

# 5.8 : libstdc++
build_stdlibcxx() {
	PKG=libstdc++-7.3.0
	echo "making $PKG"
	cd $SRCS/gcc-7.3.0
	if [ -d build ]; then
		rm -rfv build
	fi
	mkdir -v build
	cd build
	../libstdc++-v3/configure           \
    	--host=$LFS_TGT                 \
		--prefix=/tools                 \
		--disable-multilib              \
		--disable-nls                   \
		--disable-libstdcxx-threads     \
		--disable-libstdcxx-pch         \
		--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.3.0
	compile $PKG
	make install
}

# 5.9 : binutils (step 2)
build_binutils_step2() {
	PKG=binutils-2.30
	echo "making $PKG step 2"
	cd $SRCS/$PKG
	if [ -d build ]; then
		rm -rfv build
	fi
	mkdir -v build
	cd build
	CC=/tools/bin/$LFS_TGT-gcc                \
		AR=/tools/bin/$LFS_TGT-ar             \
		RANLIB=/tools/bin/$LFS_TGT-ranlib     \
		../configure               \
    	--prefix=/tools            \
    	--disable-nls              \
    	--disable-werror           \
		--with-lib-path=/tools/lib \
		--with-sysroot
	compile $PKG
	make install
	make -C ld clean
	make -C ld LIB_PATH=/usr/lib:/lib
	cp -v ld/ld-new /tools/bin
	ln -sv gcc /tools/bin/cc
	echo "$PKG done."
}

# 5.10 : gcc step 2
build_gcc_step2() {
	PKG=gcc-7.3.0
	echo "making $PKG step 2"
	cd $SRCS
	if [ -d $PKG ]; then
		rm -rfv $PKG
	fi
	tar -xf $SOURCES/$PKG.tar.xz
	cd $PKG
	tar -xf $SOURCES/mpfr-4.0.1.tar.xz
	mv -v mpfr-4.0.1 mpfr
	tar -xf $SOURCES/gmp-6.1.2.tar.xz
	mv -v gmp-6.1.2 gmp
	tar -xf $SOURCES/mpc-1.1.0.tar.gz
	mv -v mpc-1.1.0 mpc

	cat gcc/limitx.h gcc/glimits.h gcc/limity.h >  `dirname \
		$($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

	for file in gcc/config/{linux,i386/linux{,64}}.h
	do
		cp -uv $file{,.orig}
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
			-e 's@/usr@/tools@g' $file.orig > $file
		echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
		touch $file.orig
	done

	case $(uname -m) in
		x86_64)
			echo "patching 64 bits path"
			sed -e '/m64=/s/lib64/lib/' \
				-i.orig gcc/config/i386/t-linux64
			;;
	esac

	mkdir -v build
	cd build
	CC=$LFS_TGT-gcc                                    \
		CXX=$LFS_TGT-g++                               \
		AR=$LFS_TGT-ar                                 \
		RANLIB=$LFS_TGT-ranlib                         \
		../configure                                   \
		--prefix=/tools                                \
		--with-local-prefix=/tools                     \
		--with-native-system-header-dir=/tools/include \
		--enable-languages=c,c++                       \
		--disable-libstdcxx-pch                        \
		--disable-multilib                             \
		--disable-bootstrap                            \
		--disable-libgomp
	compile $PKG $MAXCORE
	make install
	echo 'int main(){}' > dummy.c
	$LFS_TGT-gcc dummy.c
	readelf -l a.out | grep ': /tools'
}

# 5.11 : Tcl-core
build_tclcore() {
	PKG=tcl8.6.8
	echo "making $PKG"
	extract $PKG-src.tar.gz
	cd $PKG/unix
	./configure --prefix=/tools
	compile $PKG
	make install
	chmod -v u+w /tools/lib/libtcl8.6.so
	make install-private-headers
	ln -sv tclsh8.6 /tools/bin/tclsh
	echo "$PKG done"
}

# 5.12 : Expect
build_expect() {
	PKG=expect5.45.4
	echo "making $PKG"
	extract $PKG.tar.gz
	cd $PKG
	cp -v configure{,.orig}
	sed 's:/usr/local/bin:/bin:' configure.orig > configure
	./configure --prefix=/tools       \
				--with-tcl=/tools/lib \
				--with-tclinclude=/tools/include
	compile $PKG
	make SCRIPTS="" install
	echo "$PKG done"
}

# 5.13 : DejaGNU
build_dejagnu() {
	PKG=dejagnu-1.6.1
	echo "making $PKG"
	extract $PKG.tar.gz
	cd $PKG
	./configure --prefix=/tools
	make install
	echo "$PKG done"
}

# 5.14 : M4
build_m4() {
	PKG=m4-1.4.18
	build_generic $PKG $PKG.tar.xz
}

# 5.15
build_ncurses() {
	PKG=ncurses-6.1
	echo "Building $PKG"
	extract $PKG.tar.gz
	cd $PKG
	sed -i s/mawk// configure
	./configure --prefix=/tools \
				--with-shared   \
				--without-debug \
				--without-ada   \
				--enable-widec  \
				--enable-overwrite
	compile $PKG
	make install
	echo "$PKG done."
}

# 5.16
build_bash() {
	build_generic bash-4.4.18 bash-4.4.18.tar.gz --without-bash-malloc	# 5.16
	ln -sv bash /tools/bin/sh
}

# 5.19 : coreutils
build_coreutils() {
	build_generic coreutils-8.29 coreutils-8.29.tar.xz \
		--enable-install-program=hostname
}

# 5.24 : gettext
build_deftext() {
	PKG=gettext-0.19.8.1
	extract $PKG.tar.xz
	cd $PKG/gettext-tools
	EMACS="no" ./configure --prefix=/tools --disable-shared
	make -C gnulib-lib
	make -C intl pluralx.c
	make -C src msgfmt
	make -C src msgmerge
	make -C src xgettext
	cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin
}

# 5.27 : make
build_make() {
	PKG=make-4.2.1
	extract $PKG.tar.bz2
	cd $PKG
	sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
	./configure --prefix=/tools --without-guile
	compile $PKG
	make install
}

#5.29
build_perl() {
	PKG=perl-5.26.1
	extract $PKG.tar.xz
	cd $PKG
	sh Configure -des -Dprefix=/tools -Dlibs=-lm
	compile $PKG
	cp -v perl cpan/podlators/scripts/pod2man /tools/bin
	mkdir -pv /tools/lib/perl5/5.26.1
	cp -Rv lib/* /tools/lib/perl5/5.26.1
	echo "$PKG done."
}

# 5.33 : util-linux
build_utillinux() {
	PKG=util-linux-2.31.1
	extract $PKG.tar.xz
	cd $PKG
	./configure --prefix=/tools                \
				--without-python               \
				--disable-makeinstall-chown    \
				--without-systemdsystemunitdir \
				--without-ncurses              \
				PKG_CONFIG=""
	compile $PKG
	make install
	echo "$PKG done."

}

# 5.35 : clean symbols in objs
clean_objs() {
	strip --strip-debug /tools/lib/*
	/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
	find /tools/{lib,libexec} -name \*.la -delete
}

# 5 : construire un systeme temporaire
create_tools() {
	get_sources
	mk_tools
	build_binutils_step1												# 5.4
	build_gcc_step1														# 5.5
	build_api_headers													# 5.6
	build_glibc															# 5.7
	build_stdlibcxx														# 5.8
	build_binutils_step2												# 5.9
	build_gcc_step2														# 5.10
	build_tclcore														# 5.11
	build_expect														# 5.12
	build_dejagnu														# 5.13
	build_generic m4-1.4.18 m4-1.4.18.tar.xz							# 5.14
	build_ncurses														# 5.15
	build_bash															# 5.16
	build_generic bison-3.0.4 bison-3.0.4.tar.xz						# 5.17
	build_generic bzip2-1.0.6 bzip2-1.0.6.tar.gz "" PREFIX=/tools		# 5.18
	build_coreutils														# 5.19
	build_generic diffutils-3.6 diffutils-3.6.tar.xz					# 5.20
	build_generic file-5.32 file-5.32.tar.gz							# 5.21
	build_generic findutils-4.6.0 findutils-4.6.0.tar.gz				# 5.22
	build_generic gawk-4.2.1 gawk-4.2.1.tar.xz							# 5.23
	build_deftext														# 5.24
	build_generic grep-3.1 grep-3.1.tar.xz								# 5.25
	build_generic gzip-1.9 gzip-1.9.tar.xz								# 5.26
	build_make															# 5.27
	build_generic patch-2.7.6 patch-2.7.6.tar.xz						# 5.28
	build_perl															# 5.29
	build_generic sed-4.4 sed-4.4.tar.xz								# 5.30
	build_generic tar-1.30 tar-1.30.tar.xz								# 5.31
	build_generic texinfo-6.5 texinfo-6.5.tar.xz						# 5.32
	build_utillinux														# 5.33
	build_generic xz-5.2.3 xz-5.2.3.tar.xz								# 5.34
	# clean_objs														# 5.35
	echo "Stage 5 complete ! it's something !"
}

################################################################################


# 6.2 : symlinks and kernel
sysmount() {
	mkdir -pv $LFS/{dev,proc,sys,run}
	sudo \
		mknod -m 600 $LFS/dev/console c 5 1 ;\
		mknod -m 666 $LFS/dev/null c 1 3 ;\
		mount -vo bind /dev $LFS/dev ;\
		mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620 ;\
		mount -vt proc proc $LFS/proc ;\
		mount -vt sysfs sysfs $LFS/sys ;\
		mount -vt tmpfs tmpfs $LFS/run
	if [ -h $LFS/dev/shm ]; then
		mkdir -pv $LFS/$(readlink $LFS/dev/shm)
	fi
	echo "sysmount done"
}

echo "target: $LFS"

# 5.0
# create_tools

# 6.0
echo "please run:"
echo "sudo ./lfs.sh"
# chexec /bin/bash
