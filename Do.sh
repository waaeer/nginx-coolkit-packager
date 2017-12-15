#!/bin/bash
set -e -u

NGV="1.12.2"
ECHO="0.61"
ECHOA="d95da35"
LUAMOD="0.10.11"
NDK="0.3.0"
NGINXPGV="1.0rc7"
SETMISC="0.31"

test -d work || mkdir work

cd work

echo geting software

echo  nginx-$NGV ----------------
test -f nginx-$NGV.tar.gz    || wget -c http://nginx.org/download/nginx-$NGV.tar.gz

echo nginx-upload-module ----------
test -d nginx-upload-module || (git clone https://github.com/vkholodkov/nginx-upload-module && (cd nginx-upload-module && git checkout 2.2))

echo nginx-upload-progress-module ----------
test -d nginx-upload-progress-module ||  git clone git://github.com/masterzen/nginx-upload-progress-module.git 

echo echo-nginx-module ------------
test -f nginx-$ECHO.zip || wget --no-check-certificate -c https://github.com/agentzh/echo-nginx-module/zipball/v$ECHO -O nginx-$ECHO.zip

#test -d echo-nginx-module ||git clone https://github.com/openresty/echo-nginx-module.git
echo ngx_cache_purge ------------
test -d ngx_cache_purge || git clone git://github.com/FRiCKLE/ngx_cache_purge.git 

echo lua-nginx-module -------------
test -f v$LUAMOD.tar.gz || wget -c https://github.com/openresty/lua-nginx-module/archive/v$LUAMOD.tar.gz -O v$LUAMOD.tar.gz

echo ngx_devel_kit ----------------
test -f v$NDK.tar.gz    || wget -c https://github.com/simpl/ngx_devel_kit/archive/v$NDK.tar.gz -O ./v$NDK.tar.gz

echo ngx_postgres --------------
test -f $NGINXPGV.tar.gz|| wget -c https://github.com/FRiCKLE/ngx_postgres/archive/$NGINXPGV.tar.gz 

echo nginx-auth-ldap ------------
test -d nginx-auth-ldap || git clone https://github.com/kvspb/nginx-auth-ldap.git

echo nginx-set_misc
test -d setmisc.tgz || wget -O setmisc.tgz -c https://github.com/openresty/set-misc-nginx-module/archive/v$SETMISC.tar.gz

test -d ./nginx-$NGV                         || tar -xzf ./nginx-$NGV.tar.gz
test -d ./openresty-echo-nginx-module-$ECHOA           || unzip    ./nginx-$ECHO.zip
test -d ./lua-nginx-module-$LUAMOD           || tar -xzf ./v$LUAMOD.tar.gz
test -d ./ngx_devel_kit-$NDK                 || tar -xzf ./v$NDK.tar.gz
test -d ./ngx_postgres-$NGINXPGV             || tar -xzf ./$NGINXPGV.tar.gz
test -d ./set-misc-nginx-module-$SETMISC     || tar -xzf ./setmisc.tgz

test -d ./nginx-$NGV/add-modules || mkdir ./nginx-$NGV/add-modules

rm -rf ./nginx-$NGV/add-modules/*

cp -r ./ngx_cache_purge                    ./nginx-$NGV/add-modules/
cp -r ./nginx-upload-module                ./nginx-$NGV/add-modules/
cp -r ./nginx-upload-progress-module       ./nginx-$NGV/add-modules/
cp -r ./lua-nginx-module-$LUAMOD           ./nginx-$NGV/add-modules/lua-nginx-module
cp -r ./ngx_devel_kit-$NDK                 ./nginx-$NGV/add-modules/ngx_devel_kit
cp -r ./ngx_postgres-$NGINXPGV             ./nginx-$NGV/add-modules/ngx_postgres
cp -r ./openresty-echo-nginx-module-$ECHOA           ./nginx-$NGV/add-modules/echo-nginx-module
cp -r ./nginx-auth-ldap 		   ./nginx-$NGV/add-modules/
cp -r ./set-misc-nginx-module-$SETMISC     ./nginx-$NGV/add-modules/set-misc-nginx-module


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

## make the tarball 
test -d ../build || mkdir ../build

tar -czf ../build/nginx-coolkit_$NGV.orig.tar.gz nginx-$NGV

## package it

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y  install build-essential  fakeroot devscripts debhelper 

# build-deps of nginx

sudo apt-get install -y autotools-dev debhelper dh-systemd libexpat-dev libgd2-noxpm-dev \
 libgeoip-dev liblua5.1-dev libmhash-dev libpam0g-dev libpcre3-dev libperl-dev libssl-dev \
 libxslt1-dev po-debconf zlib1g-dev  luajit perl libldap2-dev
sudo apt-get install -y postgrespro-server-dev-9.5 || sudo apt-get install -y postgresql-server-dev-9.5 ||dpkg -i  http://apt.postgresql.org/pub/repos/apt/pool/main/p/postgresql-9.5/postgresql-server-dev-9.5_9.5.3-1.pgdg14.04+1_amd64.deb

cd ../build
rm -rf nginx-$NGV
tar xzf nginx-coolkit_$NGV.orig.tar.gz
cd  nginx-$NGV
#checkver
dpkg-source --commit
debuild -us -uc

cd ..
rm -rf nginx-$NGV   # cleanup 

exit 0




