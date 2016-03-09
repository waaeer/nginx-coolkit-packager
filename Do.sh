set -e -u

NGV="1.8.1"
ECHO="0.38rc1"
ECHOA="6c1f553"
LUAMOD="0.10.0"
NDK="0.2.19"
NGINXPGV="1.0rc7"

test -d work || mkdir work

cd work

## get software
test -f nginx-$NGV.tar.gz    || wget -c http://nginx.org/download/nginx-$NGV.tar.gz
test -d nginx-upload-module || (git clone https://github.com/vkholodkov/nginx-upload-module && (cd nginx-upload-module && git checkout 2.2))
test -d nginx-upload-progress-module ||  git clone git://github.com/masterzen/nginx-upload-progress-module.git 
test -f nginx-$ECHO.zip || wget --no-check-certificate -c https://github.com/agentzh/echo-nginx-module/zipball/v$ECHO -O nginx-$ECHO.zip
test -d ngx_cache_purge || git clone git://github.com/FRiCKLE/ngx_cache_purge.git 
test -f v$LUAMOD.tar.gz || wget -c https://github.com/openresty/lua-nginx-module/archive/v$LUAMOD.tar.gz -O v$LUAMOD.tar.gz
test -f v$NDK.tar.gz    || wget -c https://github.com/simpl/ngx_devel_kit/archive/v$NDK.tar.gz -O ./v$NDK.tar.gz
test -f $NGINXPGV.tar.gz|| wget -c https://github.com/FRiCKLE/ngx_postgres/archive/$NGINXPGV.tar.gz 

test -d ./nginx-$NGV                         || tar -xzf ./nginx-$NGV.tar.gz
test -d ./openresty-echo-nginx-module-$ECHOA || unzip    ./nginx-$ECHO.zip
test -d ./lua-nginx-module-$LUAMOD           || tar -xzf ./v$LUAMOD.tar.gz
test -d ./ngx_devel_kit-$NDK                 || tar -xzf ./v$NDK.tar.gz
test -d ./ngx_postgres-$NGINXPGV             || tar -xzf ./$NGINXPGV.tar.gz

test -d ./nginx-$NGV/add-modules || mkdir ./nginx-$NGV/add-modules

rm -rf ./nginx-$NGV/add-modules/*

cp -r ./ngx_cache_purge                    ./nginx-$NGV/add-modules/
cp -r ./nginx-upload-module                ./nginx-$NGV/add-modules/
cp -r ./nginx-upload-progress-module       ./nginx-$NGV/add-modules/
cp -r ./lua-nginx-module-$LUAMOD           ./nginx-$NGV/add-modules/lua-nginx-module
cp -r ./ngx_devel_kit-$NDK                 ./nginx-$NGV/add-modules/ngx_devel_kit
cp -r ./ngx_postgres-$NGINXPGV             ./nginx-$NGV/add-modules/ngx_postgres
cp -r ./openresty-echo-nginx-module-$ECHOA ./nginx-$NGV/add-modules/openresty-echo-nginx-module

#(cd work  rm ./nginx-$NGV.tar.gz)
#(cd work && rm ./nginx-$ECHO.zip)
#(cd work && rm ./v$LUAMOD.tar.gz)
#(cd work && rm ./v$NDK.tar.gz)
#(cd work && rm ./$NGINXPGV.tar.gz)  

## provide control files
test -d ./nginx-$NGV/debian/ || mkdir ./nginx-$NGV/debian
cp -r ../debian/* ./nginx-$NGV/debian/


#  dch --create -v 1.8.1-1 - --package nginx-coolkit

## make the tarball 
test -d ../build || mkdir ../build

tar -czf ../build/nginx-coolkit_$NGV.orig.tar.gz nginx-$NGV

## package it

echo APT-GET 1

sudo apt-get -y  install build-essential  fakeroot devscripts debhelper 

# build-deps of nginx

sudo apt-get install -y autotools-dev debhelper dh-systemd libexpat-dev libgd2-noxpm-dev \
 libgeoip-dev liblua5.1-dev libmhash-dev libpam0g-dev libpcre3-dev libperl-dev libssl-dev \
 libxslt1-dev po-debconf zlib1g-dev postgresql-server-dev-9.5 luajit perl

cd ../build
rm -rf nginx-$NGV
tar xzf nginx-coolkit_$NGV.orig.tar.gz
cd  nginx-$NGV
debuild -us -uc

exit 0




