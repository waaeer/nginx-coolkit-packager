#!/bin/bash
set -e -u

NGV="1.28.0"               # 

ECHO="0.63"                # https://github.com/openresty/echo-nginx-module/releases
LUAMOD="0.10.28"           # https://github.com/openresty/lua-nginx-module/releases
LUARJIT2="2.1-20250529"    # https://github.com/openresty/luajit2/releases
#  Required by Lua module since 0.10.16
LUARCORE="0.1.31"          # https://github.com/openresty/lua-resty-core/releases
LUARLRUCACHE="0.15"        # https://github.com/openresty/lua-resty-lrucache/releases
NDK="0.3.4"                # https://github.com/vision5/ngx_devel_kit/releases
NGINXPGV="1.0rc7"          # https://github.com/FRiCKLE/ngx_postgres/releases
SETMISC="0.33"             # https://github.com/openresty/set-misc-nginx-module/releases
OPENSSL="3.6.0"
LIBGD="2.3.3"              #https://github.com/libgd/libgd/releases


test -d work || mkdir work

en() { 
  echo ======= $1 $2
  test -d $1 || (wget -O - $2 | tar -xzf - )
}

et () {
  echo ===== $1-$2
  test -d    $1  || (wget -O - $3 | (tar -xzf - ; mv $1-$2 $1 ))
  cp -r $1 ./nginx-$NGV/add-modules/
}

eg () { 
  echo ===* $1
  test -d   $1 || git clone $2
  cp -r $1 ./nginx-$NGV/add-modules/
}

cd work
echo ===== geting software

en nginx-$NGV            https://nginx.org/download/nginx-$NGV.tar.gz

test -d ./nginx-$NGV/add-modules || mkdir -p ./nginx-$NGV/add-modules
rm  -rf ./nginx-$NGV/add-modules/*

et echo-nginx-module     $ECHO         https://github.com/openresty/echo-nginx-module/archive/refs/tags/v$ECHO.tar.gz
et lua-resty-core        $LUARCORE     https://github.com/openresty/lua-resty-core/archive/v$LUARCORE.tar.gz
et lua-resty-lrucache    $LUARLRUCACHE https://github.com/openresty/lua-resty-lrucache/archive/v$LUARLRUCACHE.tar.gz
et luajit2               $LUARJIT2     https://github.com/openresty/luajit2/archive/v$LUARJIT2.tar.gz
et lua-nginx-module      $LUAMOD       https://github.com/openresty/lua-nginx-module/archive/v$LUAMOD.tar.gz
et ngx_devel_kit         $NDK          https://github.com/simpl/ngx_devel_kit/archive/v$NDK.tar.gz
et openssl               $OPENSSL      https://www.openssl.org/source/openssl-$OPENSSL.tar.gz
et set-misc-nginx-module $SETMISC      https://github.com/openresty/set-misc-nginx-module/archive/v$SETMISC.tar.gz

en libgd                          https://github.com/libgd/libgd/releases/download/gd-$LIBGD/libgd-$LIBGD.tar.gz
eg ngx_postgres                   https://github.com/konstruxi/ngx_postgres.git
# https://github.com/FRiCKLE/ngx_postgres/archive/$NGINXPGV.tar.gz 


eg ngx_cache_purge                https://github.com/FRiCKLE/ngx_cache_purge 
eg nginx-auth-ldap                https://github.com/kvspb/nginx-auth-ldap
eg nginx-upload-progress-module   https://github.com/waaeer/nginx-upload-progress-module 
eg nginx-upload-module            https://github.com/waaeer/nginx-upload-module
# (git clone https://github.com/vkholodkov/nginx-upload-module && (cd nginx-upload-module && git checkout 2.255))
# (git clone https://github.com/fdintino/nginx-upload-module   && (cd nginx-upload-module && git checkout master))


echo ===== Untarred

## provide control files according to current debian codename
test -d ./nginx-$NGV/debian/ || mkdir ./nginx-$NGV/debian
cp -r ../debian/* ./nginx-$NGV/debian/

RELEASE=$(lsb_release -cs)
if [ -d ../debian-$RELEASE ]; then ## файлы, специфичные для отдельного релиза
	cp ../debian-$RELEASE/* ./nginx-$NGV/debian/
fi

perl -pi -e 's/nginx-coolkit \(([^\)]+)\)/nginx-coolkit ($1~'$RELEASE')/' ./nginx-$NGV/debian/changelog

# Luajit2 (resty version)

(cd luajit2 && make PREFIX=/usr && make install PREFIX=`pwd`/../nginx-$NGV/local )
##
cp -r lua-resty-core/lib/resty               nginx-$NGV/local/share/lua/5.1/
cp -r lua-resty-lrucache/lib/resty/lrucache* nginx-$NGV/local/share/lua/5.1/resty/




## make the tarball 
test -d ../build || mkdir ../build

tar -czf ../build/nginx-coolkit_$NGV.orig.tar.gz nginx-$NGV

PCREV=3
if [ "$RELEASE" = "trixie" ] ; then
   PCREV=2
fi


sudo apt-get install -y autotools-dev debhelper \
 libexpat-dev  \
 libgeoip-dev liblua5.1-dev  libmhash-dev libpam0g-dev libpcre$PCREV-dev libperl-dev libssl-dev \
 libxslt1-dev po-debconf zlib1g-dev perl libldap2-dev libmd-dev 
sudo apt-get install -y libpq-dev 

sudo apt-get -y install dh-systemd || true;  ## если нет - значит не нужно


if [ "$RELEASE" = "trixie" ] ; then  
  ## для сборки libgd с патчем нужно использовать старые версии autoconf и automake
  echo 'deb-src http://deb.debian.org/debian stable main contrib non-free' > /etc/apt/sources.list.d/src.list
  apt update
  rm -rf libgd2-$LIBGD
  apt source libgd-dev
  en automake http://ftp.gnu.org/gnu/automake/automake-1.16.tar.gz
  en autoconf http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
  (cd automake-1.16 && ./configure --prefix /usr/tmp && make install)
  (cd autoconf-2.69 && ./configure --prefix /usr/tmp && make install)
  (
    cd libgd2-$LIBGD 
    patch -p1 < ../../gd-$LIBGD.patch
    export PATH=/usr/tmp/bin:$PATH 
    export M4PATH=/usr/tmp/share/autoconf:/usr/tmp/share/aclocal-1.16:/usr/share/aclocal 
    export ACLOCAL_PATH=/usr/tmp/share/autoconf:/usr/tmp/share/aclocal-1.16:/usr/share/aclocal
    aclocal
    automake
    autoconf
    ./configure --with-exif --with-jpeg --with-png --with-heif --with-tiff --with-webp --without-freetype --without-fontconfig --without-xpm
    make
    mv src/.libs/libgd.* ../../build/
  )
else
(
  cd libgd-$LIBGD && patch -p1 < ../../gd-$LIBGD.patch && autoconf &&\
   ./configure --with-exif --with-jpeg --with-png --with-heif --with-tiff --with-webp --without-freetype --without-fontconfig --without-xpm &&\
   make && mv src/.libs/libgd.* ../../build/
)
fi

cd ../build
rm -rf nginx-$NGV
tar xzf nginx-coolkit_$NGV.orig.tar.gz
cd  nginx-$NGV

#checkver
#dpkg-source --build #--commit

echo "DEBUILD"

debuild -us -uc -j4

cd ..
#rm -rf nginx-$NGV   # cleanup 
#rm -rf luajit2-*
#rm -rf lua-nginx-module* lua-resty-core-* lua-resty-lrucache-* nginx-auth-ldap* nginx-upload-module* nginx-upload-progress-module*
#rm -rf ngx_cache_purge* ngx_devel_kit-* ngx_postgres openresty-echo-nginx-module-* set-misc-nginx-module-*
exit 0




