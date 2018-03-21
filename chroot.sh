#!/tools/bin/bash
export SRCS=/usr/src
export SOURCES=$SRCS/sources
export LFS_USER=snicolet

extract() {
	PKG=$1
	FILE=$PKG.tar.$2
	cd $SRCS
	if [ ! -f $SOURCES/$FILE ]; then
		echo "error: unable to find $FILE"
		exit 1
	fi
	if [ -d $PKG ]; then
		echo "Cleaning previous installation"
		rm -rv $PKG
	fi
	echo "Extracting $PKG"
	tar -xf $SOURCES/$FILE
	if [ ! -d $PKG ]; then
		echo "failed to unpack source, check if $FILE exists"
		exit 1
	fi
	cd $PKG
	echo "Extraction ok"
}

compile() {
	PKG=$1
	make -j$2
	if [ $? != "0" ]; then
		echo "error: failed to compile $PKG"
		exit 1
	fi
	echo "$PKG compiled successfully"
}

# usage [package dir] <option for configure> <max cores to use for build>
build() {
	PKG=$1
	echo "Building $PKG"
	cd $SRCS/$PKG
	echo "$(pwd)"
	if [ -f configure ]; then
		echo "configure found, running it."
		echo "extra options: $CFG"
		./configure --prefix=/usr $CFG
	fi
	unset CFG
	compile $PKG $3
	if [ ! $NOINSTALL ]; then
		echo "Installing $PKG"
		make install
	else
		echo "Automatic install disabled."
		unset NOINSTALL
	fi
}

dobin() {
	PKG=$1
	EXT=$2
	export CFG=$3
	extract $PKG $EXT
	build $PKG
}

# 6.5
make_dirs() {
	mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
	mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
	mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
	mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -v  /usr/libexec
	mkdir -pv /usr/{,local/}share/man/man{1..8}

	case $(uname -m) in
		x86_64) mkdir -v /lib64 ;;
	esac

	mkdir -v /var/{log,mail,spool}
	ln -sv /run /var/run
	ln -sv /run/lock /var/lock
	mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}
}

# 6.6
make_symlinks() {
	ln -sv /tools/bin/{bash,cat,dd,echo,ln,pwd,rm,stty} /bin
	ln -sv /tools/bin/{env,install,perl} /usr/bin
	ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
	ln -sv /tools/lib/libstdc++.{a,so{,.6}} /usr/lib
	for lib in blkid lzma mount uuid
	do
		ln -sv /tools/lib/lib$lib.so* /usr/lib
	done
	ln -svf /tools/include/blkid    /usr/include
	ln -svf /tools/include/libmount /usr/include
	ln -svf /tools/include/uuid     /usr/include
	install -vdm755 /usr/lib/pkgconfig
	for pc in blkid mount uuid
	do
		sed 's@tools@usr@g' /tools/lib/pkgconfig/${pc}.pc \
			> /usr/lib/pkgconfig/${pc}.pc
	done
	ln -sv bash /bin/sh
	ln -sv /proc/self/mounts /etc/mtab
	cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
systemd-network:x:76:76:systemd Network Management:/:/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF
	cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
kvm:x:61:
systemd-bus-proxy:x:72:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
nogroup:x:99:
users:x:999:
EOF
	touch /var/log/{btmp,lastlog,faillog,wtmp}
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp
}

linux_headers() {
	PKG=linux-4.15.7
	extract $PKG xz
	echo "current path: $(pwd)"
	make mrproper
	make INSTALL_HDR_PATH=dest headers_install
	find dest/include \( -name .install -o -name ..install.cmd \) -delete
	cp -rv dest/include/* /usr/include
}

man_pages() {
	PKG=man-pages-4.15
	extract $PKG xz
	build $PKG
}

glibc() {
	PKG=glibc-2.27
	extract $PKG xz
	cd $PKG
	echo "$(pwd)"
	patch -Np1 -i $SOURCES/glibc-2.27-fhs-1.patch
	ln -sfv /tools/lib/gcc /usr/lib
	case $(uname -m) in
		i?86)    GCC_INCDIR=/usr/lib/gcc/$(uname -m)-pc-linux-gnu/7.3.0/include
            ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
	    ;;
		x86_64) GCC_INCDIR=/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include
            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
		;;
	esac
	rm -f /usr/include/limits.h
	mkdir -v build
	cd build
	CC="gcc -isystem $GCC_INCDIR -isystem /usr/include"		\
		../configure --prefix=/usr                          \
					--disable-werror                      	\
					--enable-kernel=3.2                   	\
					--enable-stack-protector=strong       	\
					libc_cv_slibdir=/lib
	unset GCC_INCDIR
	make -j6
	make check
	touch /etc/ld.so.conf
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
	make install
	cp -v ../nscd/nscd.conf /etc/nscd.conf
	mkdir -pv /var/cache/nscd
	install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
	install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service
	mkdir -pv /usr/lib/locale
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
	localedef -i de_DE -f ISO-8859-1 de_DE
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
	localedef -i de_DE -f UTF-8 de_DE.UTF-8
	localedef -i en_GB -f UTF-8 en_GB.UTF-8
	localedef -i en_HK -f ISO-8859-1 en_HK
	localedef -i en_PH -f ISO-8859-1 en_PH
	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	localedef -i es_MX -f ISO-8859-1 es_MX
	localedef -i fa_IR -f UTF-8 fa_IR
	localedef -i fr_FR -f ISO-8859-1 fr_FR
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
	localedef -i it_IT -f ISO-8859-1 it_IT
	localedef -i it_IT -f UTF-8 it_IT.UTF-8
	localedef -i ja_JP -f EUC-JP ja_JP
	localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
	localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
	localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
	localedef -i zh_CN -f GB18030 zh_CN.GB18030
	make localedata/install-locales
	cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
	tar -xf ../../tzdata2018c.tar.gz

	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}

	for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
		zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
   		zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
   		zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
	done

	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	zic -d $ZONEINFO -p America/New_York
	unset ZONEINFO
	ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime
	cat > /etc/ld.so.conf << "EOF"
# Début de /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
	cat >> /etc/ld.so.conf << "EOF"
# Ajout d'un répertoire include
include /etc/ld.so.conf.d/*.conf

EOF
	mkdir -pv /etc/ld.so.conf.d
}

fixtoolchain() {
	mv -v /tools/bin/{ld,ld-old}
	mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
	mv -v /tools/bin/{ld-new,ld}
	ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld
	gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    	-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    	-e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
		`dirname $(gcc --print-libgcc-file-name)`/specs
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'
	rm -fv dummy.c a.out dummy.log
}

zlib() {
	PKG=zlib-1.2.11
	extract $PKG xz
	build $PKG
	cd $PKG
	mv -v /usr/lib/libz.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
}

readline() {
	PKG=readline-7.0
	extract $PKG gz
	cd $PKG
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/readline-7.0
	make SHLIB_LIBS="-L/tools/lib -lncursesw" -j
	make SHLIB_LIBS="-L/tools/lib -lncurses" install
	mv -v /usr/lib/lib{readline,history}.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
	ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-7.0
}

dobc() {
	PKG=bc-1.07.1
	extract $PKG gz
	cd $PKG
	cat > bc/fix-libmath_h << "EOF"
#! /bin/bash
sed -e '1   s/^/{"/' \
    -e     's/$/",/' \
    -e '2,$ s/^/"/'  \
    -e   '$ d'       \
    -i libmath.h

sed -e '$ s/$/0}/' \
    -i libmath.h
EOF
	ln -sv /tools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
	ln -sfv libncurses.so.6 /usr/lib/libncurses.so
	sed -i -e '/flex/s/as_fn_error/: ;; # &/' configure
	./configure --prefix=/usr           \
            --with-readline         \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info
	make -j
	echo "quit" | ./bc/bc -l Test/checklib.b
	make install
}

dobinutils() {
	PKG=binutils-2.30
	extract $PKG xz
	expect -c "spawn ls"
	mkdir -v build
	cd       build
	../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib
	make tooldir=/usr -j6
	make -k check
	make tooldir=/usr install
}

dogmp() {
	PKG=gmp-6.1.2
	export CFG="--enable-cxx --disable-static --docdir=/usr/share/doc/gmp-6.1.2"
	export NOINSTALL=1
	extract $PKG xz
	build $PKG
	make check 2>&1 | tee gmp-check-log
	awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
	make install
	make install-html
	unset NOINSTALL
	unset CFG
	echo "$PKG done."
}

dompfr() {
	PKG=mpfr-4.0.1
	export CFG="--disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr-4.0.1"
	export NOINSTALL=1
	extract $PKG xz
	build $PKG
	make -j html
	make check
	make install
	make install-html
	echo "$PKG Done."
}

dompc() {
	PKG=mpc-1.1.0
	export CFG="--disable-static --docdir=/usr/share/doc/mpc-1.1.0"
	extract $PKG gz
	build $PKG
	make html
	make install-html
	echo "$PKG done"
}

dogcc() {
	PKG=gcc-7.3.0
	extract $PKG xz
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' \
       			 -i.orig gcc/config/i386/t-linux64
		;;
	esac
	rm -fv /usr/lib/gcc
	mkdir -v build
	cd build
	SED=sed                               \
	../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib

	make -j8
	ulimit -s 32768
	make -k check
	../contrib/test_summary
	unset SED
	make install
	ln -sv ../usr/bin/cpp /lib
	if [ -f /usr/bin/cc ]; then
		rm -fv /usr/bin/cc
	fi
	ln -sv gcc /usr/bin/cc
	install -v -dm755 /usr/lib/bfd-plugins
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/7.3.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
	grep -B4 '^ /usr/include' dummy.log
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
	grep "/lib.*/libc.so.6 " dummy.log
	grep found dummy.log
	rm -v dummy.c a.out dummy.log
	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	echo "$PKG done."
}

dobzip2() {
	PKG=bzip2-1.0.6
	extract $PKG gz
	patch -Np1 -i $SOURCES/bzip2-1.0.6-install_docs-1.patch
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	make -f Makefile-libbz2_so
	make clean
	make -j
	make PREFIX=/usr install
	cp -v bzip2-shared /bin/bzip2
	cp -av libbz2.so* /lib
	ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
	rm -v /usr/bin/{bunzip2,bzcat,bzip2}
	ln -sv bzip2 /bin/bunzip2
	ln -sv bzip2 /bin/bzcat
	echo "$PKG done."
}

dopkgconfig() {
	PKG=pkg-config-0.29.2
	dobin $PKG gz "--with-internal-glib --disable-host-tool --docdir=/usr/share/doc/pkg-config-0.29.2"

}

doncurses() {
	PKG=ncurses-6.1
	export CFG="--mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec"
	extract $PKG gz
	sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
	build $PKG
	mv -v /usr/lib/libncursesw.so.6* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
	for lib in ncurses form panel menu ; do
		rm -vf                    /usr/lib/lib${lib}.so
		echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
		ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
	done
	rm -vf                     /usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
	ln -sfv libncurses.so      /usr/lib/libcurses.so
	mkdir -v       /usr/share/doc/ncurses-6.1
	cp -v -R doc/* /usr/share/doc/ncurses-6.1
	unset CFG
}

doattr() {
	PKG=attr-2.4.47
	ln -sv $SOURCES/$PKG.src.tar.gz $SOURCES/$PKG.tar.gz
	extract $PKG gz
	sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
	sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile
	sed -i 's:{(:\\{(:' test/run
	./configure --prefix=/usr --disable-static
	make install install-dev install-lib
	chmod -v 755 /usr/lib/libattr.so
	mv -v /usr/lib/libattr.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
}

doacl() {
	PKG=acl-2.2.52
	export CFG="--disable-static --libexecdir=/usr/lib"
	ln -sv $SOURCES/$PKG.src.tar.gz $SOURCES/$PKG.tar.gz
	extract $PKG gz
	sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
	sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
	sed -i 's/{(/\\{(/' test/run
	sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
		libacl/__acl_to_any_text.c
	build $PKG
	make install-dev install-lib
	chmod -v 755 /usr/lib/libacl.so
	mv -v /usr/lib/libacl.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
	echo "$PKG done."
}

dolibcap() {
	PKG=libcap-2.25
	extract $PKG xz
	sed -i '/install.*STALIBNAME/d' libcap/Makefile
	make -j
	make RAISE_SETFCAP=no lib=lib prefix=/usr install
	chmod -v 755 /usr/lib/libcap.so
	mv -v /usr/lib/libcap.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so
	echo "$PKG done."
}

dosed() {
	PKG=sed-4.4
	extract $PKG xz
	sed -i 's/usr/tools/'                 build-aux/help2man
	sed -i 's/testsuite.panic-tests.sh//' Makefile.in
	./configure --prefix=/usr --bindir=/bin
	make -j
	make html
	make install
	install -d -m755           /usr/share/doc/sed-4.4
	install -m644 doc/sed.html /usr/share/doc/sed-4.4
}

doshadow() {
	PKG=shadow-4.5
	extract $PKG xz
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
	sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
	sed -i 's/1000/999/' etc/useradd
	./configure --sysconfdir=/etc --with-group-name-max-length=32
	make -j
	make install
	mv -v /usr/bin/passwd /bin
	pwconv
	grpconv
	sed -i 's/yes/no/' /etc/default/useradd
}

dopsmisc() {
	PKG=psmisc-23.1
	extract $PKG xz
	build $PKG
	mv -v /usr/bin/fuser   /bin
	mv -v /usr/bin/killall /bin
	echo "$PKG done"
}

dobison() {
	PKG=bison-3.0.4
	export CFG="--docdir=/usr/share/doc/bison-3.0.4"
	extract $PKG xz
	build $PKG	
}

doflex() {
	PKG=flex-2.6.4
	extract $PKG gz
	sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
	HELP2MAN=/tools/bin/true \
		./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
	make -j
	make install
	ln -s flex /usr/bin/lex
	echo "$PKG done"
}

dobash() {
	PKG=bash-4.4.18
	extract $PKG gz
	./configure --prefix=/usr                       \
				--docdir=/usr/share/doc/bash-4.4.18 \
				--without-bash-malloc               \
				--with-installed-readline
	make -j
	chown -Rv nobody .
	su nobody -s /bin/bash -c "PATH=$PATH make tests"
	make install
	mv -vf /usr/bin/bash /bin
}

doexpat() {
	PKG=expat-2.2.5
	extract $PKG bz2
	sed -i 's|usr/bin/env |bin/|' run.sh.in
	./configure --prefix=/usr --disable-static
	make -j
	make install
	install -v -dm755 /usr/share/doc/expat-2.2.5
	install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.5
	echo "$PKG done"
}

doinetutils() {
	PKG=inetutils-1.9.4
	extract $PKG xz
	./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
	make -j
	make install
	mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
	mv -v /usr/bin/ifconfig /sbin
	echo "$PKG done."
}

doperl() {
	PKG=perl-5.26.1
	extract $PKG xz
	echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
	export BUILD_ZLIB=False
	export BUILD_BZIP2=0
	sh Configure -des -Dprefix=/usr                 \
    	              -Dvendorprefix=/usr           \
        	          -Dman1dir=/usr/share/man/man1 \
           		      -Dman3dir=/usr/share/man/man3 \
           		      -Dpager="/usr/bin/less -isR"  \
               		  -Duseshrplib                  \
                	  -Dusethreads
	compile $PKG
	make install
	unset BUILD_ZLIB BUILD_BZIP2
}

doxmlparser() {
	PKG=XML-Parser-2.44
	extract $PKG gz
	perl Makefile.PL
	compile $PKG
	make install
	echo "$PKG done"
}

dointltool() {
	PKG=intltool-0.51.0
	extract $PKG gz
	sed -i 's:\\\${:\\\$\\{:' intltool-update.in
	build $PKG
	install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
	echo "$PKG done"
}

doautomake() {
	PKG=automake-1.16
	extract $PKG xz
	./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15.1
	compile $PKG
	make install
	echo "$PKG done"
}

doxz() {
	PKG=xz-5.2.3
	extract $PKG xz
	./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.3
	compile $PKG
	make install
	mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
	mv -v /usr/lib/liblzma.so.* /lib
	ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
	echo "$PKG done."
}

dokmod() {
	PKG=kmod-25
	extract $PKG xz
	./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib
	compile $PKG
	make install
	for target in depmod insmod lsmod modinfo modprobe rmmod; do
		ln -sfv ../bin/kmod /sbin/$target
	done
	ln -sfv kmod /bin/lsmod
	echo "$PKG done."
}

dogettext() {
	PKG=gettext-0.19.8.1
	extract $PKG xz
	sed -i '/^TESTS =/d' gettext-runtime/tests/Makefile.in
	sed -i 's/test-lock..EXEEXT.//' gettext-tools/gnulib-tests/Makefile.in
	./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.8.1
	compile $PKG
	make install
	chmod -v 0755 /usr/lib/preloadable_libintl.so
	echo "$PKG done."
}

dolibelf() {
	PKG=elfutils-0.170
	extract $PKG bz2
	./configure --prefix=/usr
	compile $PKG
	make -C libelf install
	install -vm644 config/libelf.pc /usr/lib/pkgconfig
	echo "$PKG done"
}

dolibffi() {
	PKG=libffi-3.2.1
	extract $PKG gz
	sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    	-i include/Makefile.in

	sed -e '/^includedir/ s/=.*$/=@includedir@/' \
		-e 's/^Cflags: -I${includedir}/Cflags:/' \
		-i libffi.pc.in
	./configure --prefix=/usr --disable-static
	compile $PKG
	make install
	echo "$PKG done."
}

doopenssl() {
	PKG=openssl-1.1.0g
	extract $PKG gz
	./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
	compile $PKG
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
	make MANSUFFIX=ssl install
	mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.0g
	cp -vfr doc/* /usr/share/doc/openssl-1.1.0g
	echo "$PKG done."
}

dopython3() {
	PKG=Python-3.6.4
	extract $PKG xz
	./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
	compile $PKG
	make install
	if [ $? != "0" ]; then
		echo "installation of $PKG failed !"
		exit 1
	fi
	chmod -v 755 /usr/lib/libpython3.6m.so
	chmod -v 755 /usr/lib/libpython3.so
	echo "$PKG done."
}

doninja() {
	PKG=ninja-1.8.2
	extract $PKG gz
	export NINJAJOBS=4
	patch -Np1 -i $SOURCES/ninja-1.8.2-add_NINJAJOBS_var-1.patch
	python3 configure.py --bootstrap
	python3 configure.py
	./ninja ninja_test
	./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
	install -vm755 ninja /usr/bin/
	install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
	install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
	echo "$PKG done."
}

domesson() {
	PKG=meson-0.44.1
	extract $PKG gz
	python3 setup.py build
	python3 setup.py install
	echo "$PKG done"
}

dosystemd() {
	PKG=systemd-237
	extract $PKG gz
	ln -sf /tools/bin/true /usr/bin/xsltproc
	tar -xf $SOURCES/systemd-man-pages-237.tar.xz
	sed '178,222d' -i src/resolve/meson.build
	sed -i 's/GROUP="render", //' rules/50-udev-default.rules.in
	mkdir -p build
	cd       build

	LANG=en_US.UTF-8                   \
	meson --prefix=/usr                \
			--sysconfdir=/etc            \
			--localstatedir=/var         \
			-Dblkid=true                 \
			-Dbuildtype=release          \
			-Ddefault-dnssec=no          \
			-Dfirstboot=false            \
			-Dinstall-tests=false        \
			-Dkill-path=/bin/kill        \
			-Dkmod-path=/bin/kmod        \
			-Dldconfig=false             \
			-Dmount-path=/bin/mount      \
			-Drootprefix=                \
			-Drootlibdir=/lib            \
			-Dsplit-usr=true             \
			-Dsulogin-path=/sbin/sulogin \
			-Dsysusers=false             \
			-Dumount-path=/bin/umount    \
			-Db_lto=false                \
			..
	LANG=en_US.UTF-8 ninja
	LANG=en_US.UTF-8 ninja install
	rm -rfv /usr/lib/rpm
	for tool in runlevel reboot shutdown poweroff halt telinit; do
		ln -sfv ../bin/systemctl /sbin/${tool}
	done
	ln -sfv ../lib/systemd/systemd /sbin/init
	rm -f /usr/bin/xsltproc
	systemd-machine-id-setup
	cat > /lib/systemd/systemd-user-sessions << "EOF"
#!/bin/bash
rm -f /run/nologin
EOF
	chmod 755 /lib/systemd/systemd-user-sessions
	echo "$PKG done."

}

doprocps() {
	PKG=procps-ng-3.3.12
	extract $PKG xz
	./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.12 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd
	compile $PKG
	sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
	sed -i '/set tty/d' testsuite/pkill.test/pkill.exp
	rm testsuite/pgrep.test/pgrep.exp
	make install
	mv -v /usr/lib/libprocps.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
	echo "$PKG done."
}

doe2fsprogs() {
	PKG=e2fsprogs-1.43.9
	extract $PKG gz
	mkdir -v build
	cd build
	LIBS=-L/tools/lib                    \
		CFLAGS=-I/tools/include              \
		PKG_CONFIG_PATH=/tools/lib/pkgconfig \
		../configure --prefix=/usr           \
					--bindir=/bin           \
					--with-root-prefix=""   \
					--enable-elf-shlibs     \
					--disable-libblkid      \
					--disable-libuuid       \
					--disable-uuidd         \
					--disable-fsck
	compile $PKG
	ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
	make LD_LIBRARY_PATH=/tools/lib check
	make install
	make install-libs
	chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
	gunzip -v /usr/share/info/libext2fs.info.gz
	install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
	makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
	install -v -m644 doc/com_err.info /usr/share/info
	install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
	echo "$PKG done."
}

docoreutis() {
	PKG=coreutils-8.29
	extract $PKG xz
	patch -Np1 -i $SOURCES/coreutils-8.29-i18n-1.patch
	sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
	autoreconf -f -i
	FORCE_UNSAFE_CONFIGURE=1 ./configure \
			--prefix=/usr            \
            --enable-no-install-program=kill,uptime
	if [ $? != 0 ]; then
		echo "configure has failed on $PKG"
		exit 1
	fi
	FORCE_UNSAFE_CONFIGURE=1 make -j
	make NON_ROOT_USERNAME=nobody check-root
	if [ $? != 0 ]; then
		echo "error: failed to build $PKG"
		exit 1
	fi
	make install
	MV=/tools/bin/mv
	$MV -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
	$MV -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
	$MV -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
	$MV -v /usr/bin/chroot /usr/sbin
	$MV -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
	$MV -v /usr/bin/{head,sleep,nice} /bin
}

dogawk() {
	PKG=gawk-4.2.1
	extract $PKG xz
	sed -i 's/extras//' Makefile.in
	build $PKG
	mkdir -v /usr/share/doc/gawk-4.2.1
	cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.2.1
	echo "$PKG done."
}

dofindutils() {
	PKG=findutils-4.6.0
	extract $PKG gz
	sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in
	./configure --prefix=/usr --localstatedir=/var/lib/locate
	compile $PKG
	make install
	mv -v /usr/bin/find /bin
	sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb             
	echo "$PKG done"
}                                                                        
 
dogroff() {
	PKG=groff-1.22.3
	extract $PKG gz
	PAGE=A4 ./configure --prefix=/usr
	compile $PKG 1
	make install
	echo "$PKG done."
}

dogrub2() {
	PKG=grub-2.02
	CFG="--sbindir=/sbin --sysconfdir=/etc --disable-efiemu --disable-werror"
	extract $PKG xz
	build $PKG
}

dogzip() {
	dobin gzip-1.9 xz
	mv -v /usr/bin/gzip /bin
}

doiproute() {
	PKG=iproute2-4.15.0
	extract $PKG xz
	sed -i /ARPD/d Makefile
	rm -fv man/man8/arpd.8
	sed -i 's/m_ipt.o//' tc/Makefile
	compile $PKG
	make DOCDIR=/usr/share/doc/iproute2-4.15.0 install
	echo "$PKG done."
}

dokbd() {
	PKG=kbd-2.0.4
	extract $PKG xz
	patch -Np1 -i ../kbd-2.0.4-backspace-1.patch
	sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
	PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
	compile $PKG
	make install
	mkdir -v       /usr/share/doc/kbd-2.0.4
	cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.4
	echo "$PKG done."
}

domake() {
	PKG=make-4.2.1
	extract $PKG bz2
	sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
	build $PKG
}

dodbus() {
	PKG=dbus-1.12.6
	extract $PKG gz
	./configure --prefix=/usr                       \
              --sysconfdir=/etc                   \
              --localstatedir=/var                \
              --disable-static                    \
              --disable-doxygen-docs              \
              --disable-xml-docs                  \
              --docdir=/usr/share/doc/dbus-1.12.4 \
              --with-console-auth-dir=/run/console
	compile $PKG
	make install
	mv -v /usr/lib/libdbus-1.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
	ln -sv /etc/machine-id /var/lib/dbus
	echo "$PKG done."
}

doutilslinux() {
	PKG=util-linux-2.31.1
	extract $PKG xz
	mkdir -pv /var/lib/hwclock
	rm -vf /usr/include/{blkid,libmount,uuid}
	./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.31.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python
	compile $PKG
	make install
	echo "$PKG done."
}

domandb() {
	PKG=man-db-2.8.2
	extract $PKG xz
	./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.8.1 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap
	compile $PKG
	make install
	sed -i "s:man man:root root:g" /usr/lib/tmpfiles.d/man-db.conf
	echo "$PKG done."
}

dotar() {
	PKG=tar-1.30
	extract $PKG xz
	FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --bindir=/bin
	compile $PKG
	make install
	make -C doc install-html docdir=/usr/share/doc/tar-1.30
	echo "$PKG done."
}

dotexinfo() {
	PKG=texinfo-6.5
	extract $PKG xz
	./configure --prefix=/usr --disable-static
	compile $PKG
	make install
	make TEXMF=/usr/share/texmf install-tex
	pushd /usr/share/info
	rm -v dir
	for f in *
	do \
		install-info $f dir 2>/dev/null
	done
	popd
	echo "$PKG done."
}

dovim() {
	# thoses idiots devs named the content of the tar file differently that the
	# file itself, so i cannot use extract...
	PKG=vim-8.0.586
	FILE=$SOURCES/$PKG.tar.bz2
	DIR=vim80
	cd $SRCS
	if [ ! -f $FILE ]; then
		echo "failed to found source $FILE"
		exit 1
	fi
	tar -xf $FILE
	if [ ! -d $DIR ]; then
		echo "error: failed to unpack $PKG"
		exit 1
	fi
	cd $DIR
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
	sed -i '/call/{s/split/xsplit/;s/303/492/}' src/testdir/test_recover.vim
	./configure --prefix=/usr
	compile $PKG
	make install
	ln -sv vim /usr/bin/vi
	for L in  /usr/share/man/{,*/}man1/vim.1; do
		ln -sv vim.1 $(dirname $L)/vi.1
	done
	ln -sv ../vim/vim80/doc /usr/share/doc/$PKG
	cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=a
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
	echo "$PKG done."
}

dogit() {
	PKG=git-2.16.2
	URL=https://mirrors.edge.kernel.org/pub/software/scm/git/$PKG.tar.xz
	if [ ! -f $SOURCES/$PKG.tar.xz ]; then
		wget $URL -O $SOURCES/$PKG.tar.xz
	fi
	extract $PKG xz
	./configure --prefix=/usr --with-expat
	compile $PKG
	make install
	echo "$PKG done."
}

dozsh() {
	VERSION=5.4.2
	PKG=zsh-$VERSION
	URL=ftp://ftp.funet.fi/pub/unix/shells/zsh/$PKG.tar.gz
	if [ ! -f $SOURCES/$PKG.tar.gz ]; then
		echo "downloading zsh"
		wget $URL -O $SOURCES/$PKG.tar.gz
	fi
	extract $PKG gz
	build $PKG
	echo "$PKG done."
}

setup_network() {
	cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
EOF
	ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf
	echo "$LFS_USER" > /etc/hostname

	cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost
127.0.1.1 <FQDN> <HOSTNAME>
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF
}

echo "Hi from chroot"                                                    
# make_dirs                                                              
# make_symlinks                                  
# linux_headers												            # 6.7
# man_pages																# 6.8
# glibc																	# 6.9
# fixtoolchain															# 6.10
# zlib																	# 6.11
# dobin file-5.32 gz													# 6.12
# readline																# 6.13
# dobin m4-1.4.18 xz													# 6.14
# dobc																	# 6.15
# dobinutils															# 6.16
# dogmp																	# 6.17
# dompfr																# 6.18
# dompc																	# 6.19
# dogcc																	# 6.20
# dobzip2																# 6.21
# dopkgconfig															# 6.22
# doncurses																# 6.23
# doattr																# 6.24
# doacl																	# 6.25
# dolibcap																# 6.26
# dosed																	# 6.27
# doshadow																# 6.28
# dopsmisc																# 6.29
# dobin iana-etc-2.30 bz2												# 6.30
# dobison																# 6.31
# doflex																# 6.32
# dobin grep-3.1 xz --bindir=/bin										# 6.33
# dobash																# 6.34
# dobin libtool-2.4.6 xz												# 6.35
# dobin gdbm-1.14.1 gz "--disable-static --enable-libgdbm-compat"		# 6.36
# dobin gperf-3.1 gz "--docdir=/usr/share/doc/gperf-3.1"				# 6.37
# doexpat																# 6.38
# doinetutils															# 6.39
# doperl																# 6.40
# doxmlparser															# 6.41
# dointltool															# 6.42
# dobin autoconf-2.69 xz												# 6.43
# doautomake															# 6.44
# doxz																	# 6.45
# dokmod																# 6.46
# dogettext
# dolibelf
# dolibffi
# doopenssl
# dopython3
# doninja
# domesson
# dosystemd
# doprocps
# doe2fsprogs
# docoreutis
# dobin check-0.12.0 gz
# dobin diffutils-3.6 xz
# dogawk
# dofindutils
# dogroff
# dogrub2
# dobin less-530 gz --sysconfdir=/etc
# dogzip
# doiproute
# dokbd
# dobin libpipeline-1.5.0 gz
# domake
# dobin patch-2.7.6 xz
# dodbus
# doutilslinux
# domandb
# dotar
# dotexinfo
# dovim

# custon packages
# dogit
# dobin nettle-3.4 gz
# dobin gnutls-3.6.2 xz "--with-included-libtasn1 --with-included-unistring --without-p11-kit"
# dobin wget-1.19.4 gz
# dozsh

# cleaning
#rm -rfv /tmp/*
#find /usr/lib -name \*.la -delete

