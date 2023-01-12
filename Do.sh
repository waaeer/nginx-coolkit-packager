#!/bin/bash
set -e -u

NGV="1.22.1"
# https://github.com/openresty/echo-nginx-module/releases
ECHO="0.62rc1"
ECHOA="996412d"
# https://github.com/openresty/lua-nginx-module/releases
LUAMOD="0.10.16rc5"

# https://github.com/openresty/luajit2/releases
LUARJIT2="2.1-20200102"
#
#  Required by Lua module since 0.10.16
# https://github.com/openresty/lua-resty-core/releases
LUARCORE="0.1.18rc4"
# https://github.com/openresty/lua-resty-lrucache/releases
LUARLRUCACHE="0.10rc1"

# https://github.com/vision5/ngx_devel_kit/releases
NDK="0.3.1"
# https://github.com/FRiCKLE/ngx_postgres/releases
NGINXPGV="1.0rc7"
# https://github.com/openresty/set-misc-nginx-module/releases
SETMISC="0.32"
OPENSSL="3.0.7"

test -d work || mkdir work

cd work

echo geting software

echo  nginx-$NGV ----------------
test -f nginx-$NGV.tar.gz    || wget -c http://nginx.org/download/nginx-$NGV.tar.gz

echo nginx-upload-module ----------
##test -d nginx-upload-module || (git clone https://github.com/vkholodkov/nginx-upload-module && (cd nginx-upload-module && git checkout 2.255))
#test -d nginx-upload-module || (git clone https://github.com/fdintino/nginx-upload-module && (cd nginx-upload-module && git checkout master))
test -d nginx-upload-module || (git clone https://github.com/waaeer/nginx-upload-module && (cd nginx-upload-module && git checkout master))


echo nginx-upload-progress-module ----------
test -d nginx-upload-progress-module ||  git clone https://github.com/masterzen/nginx-upload-progress-module.git 

echo echo-nginx-module ------------
test -f nginx-$ECHO.zip || wget --no-check-certificate -c https://github.com/agentzh/echo-nginx-module/zipball/v$ECHO -O nginx-$ECHO.zip

#test -d echo-nginx-module ||git clone https://github.com/openresty/echo-nginx-module.git
echo ngx_cache_purge ------------
test -d ngx_cache_purge || git clone https://github.com/FRiCKLE/ngx_cache_purge.git 

# 
echo lua-resty-core ------------
test -f v$LUARCORE.tar.gz     || wget -c https://github.com/openresty/lua-resty-core/archive/v$LUARCORE.tar.gz

echo lua-resty-lrucache ------
test -f v$LUARLRUCACHE.tar.gz || wget -c https://github.com/openresty/lua-resty-lrucache/archive/v$LUARLRUCACHE.tar.gz

echo luajit by openresty ---
test -f v$LUARJIT2.tar.gz     || wget -c https://github.com/openresty/luajit2/archive/v$LUARJIT2.tar.gz


echo lua-nginx-module -------------
test -f v$LUAMOD.tar.gz || wget -c https://github.com/openresty/lua-nginx-module/archive/v$LUAMOD.tar.gz -O v$LUAMOD.tar.gz

echo ngx_devel_kit ----------------
test -f v$NDK.tar.gz    || wget -c https://github.com/simpl/ngx_devel_kit/archive/v$NDK.tar.gz -O ./v$NDK.tar.gz

echo ngx_postgres --------------
#test -f $NGINXPGV.tar.gz|| wget -c https://github.com/FRiCKLE/ngx_postgres/archive/$NGINXPGV.tar.gz 
test -d ngx_postgres || git clone https://github.com/konstruxi/ngx_postgres.git

echo nginx-auth-ldap ------------
test -d nginx-auth-ldap || git clone https://github.com/kvspb/nginx-auth-ldap.git

echo nginx-set_misc

test -d setmisc.tgz || wget -O setmisc.tgz -c https://github.com/openresty/set-misc-nginx-module/archive/v$SETMISC.tar.gz
echo "setmisc done"
test -d ./nginx-$NGV                         || tar -xzf ./nginx-$NGV.tar.gz
echo "unzipping nginx-echo"
test -d ./openresty-echo-nginx-module-$ECHOA || unzip    ./nginx-$ECHO.zip
echo "open resty done"
test -d ./luajit2-$LUARJIT2.tar.gz           || tar -xzf ./v$LUARJIT2.tar.gz
echo "Luajit2 done"
test -d ./lua-nginx-module-$LUAMOD           || tar -xzf ./v$LUAMOD.tar.gz
echo "lua-nginx-module done"
test -d ./ngx_devel_kit-$NDK                 || tar -xzf ./v$NDK.tar.gz
echo "ndkk done"
#test -d ./ngx_postgres-$NGINXPGV             || tar -xzf ./$NGINXPGV.tar.gz
test -d ./set-misc-nginx-module-$SETMISC     || tar -xzf ./setmisc.tgz
echo "Set misc done"

test -d ./nginx-$NGV/add-modules || mkdir ./nginx-$NGV/add-modules

if ! [ -d ./nginx-$NGV/openssl-$OPENSSL ] ; then
    if [ -d /usr/local/src/openssl-$OPENSSL ] ; then
       cp -r /usr/local/src/openssl-$OPENSSL./nginx-$NGV
    else
		echo "getting openssl"
       wget --quiet -O - https://www.openssl.org/source/openssl-$OPENSSL.tar.gz | tar -xzf - -C ./nginx-$NGV
	fi
fi

## $LUARJIT2.tar.gz

echo Work with lua-resty-core
test -d ./lua-resty-core-$LUARCORE                        || tar -xzf v$LUARCORE.tar.gz
(cd     ./lua-resty-core-$LUARCORE         && make install PREFIX=../nginx-$NGV/local ) 
echo "LyaR $LUARCORE"
test -d ./lua-resty-lrucache-$LUARLRUCACHE                || tar -xzf v$LUARLRUCACHE.tar.gz
(cd     ./lua-resty-lrucache-$LUARLRUCACHE && make install PREFIX=../nginx-$NGV/local DESTDIR=.) 
echo "Cache done"

rm -rf ./nginx-$NGV/add-modules/*

cp -r ./ngx_cache_purge                    ./nginx-$NGV/add-modules/
cp -r ./nginx-upload-module                ./nginx-$NGV/add-modules/
cp -r ./nginx-upload-progress-module       ./nginx-$NGV/add-modules/
cp -r ./lua-nginx-module-$LUAMOD           ./nginx-$NGV/add-modules/lua-nginx-module
cp -r ./ngx_devel_kit-$NDK                 ./nginx-$NGV/add-modules/ngx_devel_kit
#cp -r ./ngx_postgres-$NGINXPGV             ./nginx-$NGV/add-modules/ngx_postgres
cp -r ./ngx_postgres			           ./nginx-$NGV/add-modules/

cp -r ./openresty-echo-nginx-module-$ECHOA ./nginx-$NGV/add-modules/openresty-echo-nginx-module
cp -r ./nginx-auth-ldap 				   ./nginx-$NGV/add-modules/
cp -r ./set-misc-nginx-module-$SETMISC     ./nginx-$NGV/add-modules/set-misc-nginx-module


## patch for OpenSSL 1.1.*
#echo "patching lua for openssl"
# not needed more?
#(cd ./nginx-$NGV/add-modules/lua-nginx-module && patch -p1 < ../../../../mod-lua-for-openssl1.1.patch )

## Check if patch is needed and apply if so for eliminating CVE-2016-4450
## look at http://mailman.nginx.org/pipermail/nginx-announce/2016/000179.html for details
## The problem affects nginx 1.3.9 - 1.11.0.
## from 1.9.13 to 1.11.0 this patch http://nginx.org/download/patch.2016.write.txt  
## from 1.3.9 to 1.9.12 this patch http://nginx.org/download/patch.2016.write2.txt 
#version(){
#    local h t v
#
#    [[ $2 = "$1" || $2 = "$3" ]] && return 0
#
#    v=$(printf '%s\n' "$@" | sort -V)
#    h=$(head -n1 <<<"$v")
#    t=$(tail -n1 <<<"$v")
#
#    [[ $2 != "$h" && $2 != "$t" ]]
#}
#
#apply-CVE-2016-4450() {
# wget $1 -O CVE-2016-4450.patch
# patch -p0 < CVE-2016-4450.patch
#}
#
#checkver(){
#
#VLOW=1.3.9
#VMID1=1.9.12
#VMID2=1.9.13
#VHIGH=1.10.0

#if version "$VLOW" "$NGV" "VHIGH"
#then
#
#        if version "$VLOW" "$NGV" "$VMID1"
#        then
#                apply-CVE-2016-4450 http://nginx.org/download/patch.2016.write2.txt
#        fi
#        if version "$VMID2" "$NGV" "$VHIGH"
#        then
#                apply-CVE-2016-4450 http://nginx.org/download/patch.2016.write.txt
#        fi
#
#else
#        echo not affected
#fi
#} 

#(cd work  rm ./nginx-$NGV.tar.gz)
#(cd work && rm ./nginx-$ECHO.zip)
#(cd work && rm ./v$LUAMOD.tar.gz)
#(cd work && rm ./v$NDK.tar.gz)
#(cd work && rm ./$NGINXPGV.tar.gz)  

## provide control files
test -d ./nginx-$NGV/debian/ || mkdir ./nginx-$NGV/debian
cp -r ../debian/* ./nginx-$NGV/debian/

RELEASE=$(lsb_release -cs)
if [ -d ../debian-$RELEASE ]; then ## файлы, специфичные для отдельного релиза
	cp ../debian-$RELEASE/* ./nginx-$NGV/debian/
fi

perl -pi -e 's/nginx-coolkit \(([^\)]+)\)/nginx-coolkit ($1~'$RELEASE')/' ./nginx-$NGV/debian/changelog
#  dch --create -v 1.8.1-1 - --package nginx-coolkit

# Luajit2 (resty version)

(cd luajit2-$LUARJIT2 && make PREFIX=/usr && make install PREFIX=`pwd`/../nginx-$NGV/local )


## make the tarball 
test -d ../build || mkdir ../build

tar -czf ../build/nginx-coolkit_$NGV.orig.tar.gz nginx-$NGV

## package it

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y  install build-essential  fakeroot devscripts debhelper 

# build-deps of nginx

#
sudo apt-get install -y autotools-dev debhelper \
 libexpat-dev  \
 libgeoip-dev liblua5.1-dev  libmhash-dev libpam0g-dev libpcre3-dev libperl-dev libssl-dev \
 libxslt1-dev po-debconf zlib1g-dev perl libldap2-dev libmd-dev libgd-dev
sudo apt-get install -y libpq-dev 

sudo apt-get -y install dh-systemd || true;  ## если нет - значит не нужно

cd ../build
rm -rf nginx-$NGV
tar xzf nginx-coolkit_$NGV.orig.tar.gz
cd  nginx-$NGV

#checkver
dpkg-source --build #--commit
debuild -us -uc -j4

cd ..
rm -rf nginx-$NGV   # cleanup 
rm -rf luajit2-*
rm -rf lua-nginx-module* lua-resty-core-* lua-resty-lrucache-* nginx-auth-ldap* nginx-upload-module* nginx-upload-progress-module*
rm -rf ngx_cache_purge* ngx_devel_kit-* ngx_postgres openresty-echo-nginx-module-* set-misc-nginx-module-*
exit 0




