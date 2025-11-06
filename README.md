# nginx-coolkit-packager
A tool for creating a debian package for a custom nginx build with upload_module, postgres and some other stuff 

# List of included software

## Nginx

The latest version of the stable branch is intended to be used.

## Nginx modules

- [http\_perl\_module](https://nginx.org/en/docs/http/ngx_http_perl_module.html) Allows perl scripting in nginx config.
- [http\_ssl\_module](https://nginx.org/en/docs/http/ngx_http_ssl_module.html) Provides the necessary support for HTTPS. Linked with latest stable version of OpenSSL.
- [http\_stub\_status\_module](https://nginx.org/en/docs/http/ngx_http_stub_status_module.html). Provides access to basic status information.
- [http\_realip\_module](https://nginx.org/en/docs/http/ngx_http_realip_module.html) Is used to change the client address and optional port to those sent in the specified header field (like X-Forwarded-For). To be used behind a proxy.
- [http_auth_request_module](https://nginx.org/en/docs/http/ngx_http_auth_request_module.html) Implements client authentication based on the result of a subrequest.
- [http_addition_module](https://nginx.org/en/docs/http/ngx_http_addition_module.html) Adds text before and after a response. 
- [http_dav_module](https://nginx.org/en/docs/http/ngx_http_dav_module.html) Provides WebDAV protocol.
- [http_flv_module](https://nginx.org/en/docs/http/ngx_http_flv_module.html) Provides FLV video pseudo-streaming.
- [http_mp4_module](https://nginx.org/en/docs/http/ngx_http_mp4_module.html) Provides MP4 video pseudo-streaming.
- [http_geoip_module](https://nginx.org/en/docs/http/ngx_http_mp4_module.html) Provides IP georesolvibg with precompiled MaxMind GeoIp database.
- [http_gunzip_module](https://nginx.org/en/docs/http/ngx_http_gunzip_module.html) Decompresses responses with ``Content-Encoding: gzip`` for clients that do not support ``gzip`` encoding method.
- [http_gzip_static_module](https://nginx.org/en/docs/http/ngx_http_gzip_static_module.html) Allows sending precompressed files with the ``.gz`` filename extension instead of regular files. 
- [http_image_filter_module](https://nginx.org/en/docs/http/ngx_http_image_filter_module.html) Scales images in JPEG, GIF, PNG, and WebP formats. Statically linked with
    a [patched](https://github.com/libgd/libgd/pull/478) version of libgd library to provide EXIF rotation handling.
- [http_sub_module](https://nginx.org/en/docs/http/ngx_http_sub_module.html) Allows substring replacement in the responses.

## 3rd party Nginx modules


- [echo](https://github.com/openresty/echo-nginx-module) Brings "echo", "sleep", "time", "exec" and more shell-style goodies to Nginx config file;
- [lua](https://github.com/openresty/lua-nginx-module) Enables Lua scripting in Nginx config file using [luajit2] (https://github.com/openresty/luajit2/) interpreter;
- [set-misc](https://github.com/openresty/set-misc-nginx-module) Various set_xxx directives added to nginx's rewrite module (md5/sha1, sql/json quoting, and many more);
- [ngx\_postgres](https://github.com/konstruxi/ngx_postgres) Allows Nginx to communicate directly with PostgreSQL database;
- [cache_purge](https://github.com/FRiCKLE/ngx_cache_purge) Adds ability to purge content from FastCGI, proxy, SCGI and uWSGI caches;
- [nginx-auth-ldap](https://github.com/kvspb/nginx-auth-ldap) Adds LDAP authentication;
- [nginx-upload](https://github.com/waaeer/nginx-upload-module) Provides uploading files to a directory on the server;
- [nginx-upload-progress](https://github.com/waaeer/nginx-upload-progress-module) Provides information on the upload progress;
- [lua-resty-core](https://github.com/openresty/lua-resty-core) A prerequisite for ngx\_http\_lua\_module and/or ngx\_stream\_lua\_module;
- [lua-resty-lrucache](https://github.com/openresty/lua-resty-lrucache) A prerequisite for ngx\_http\_lua\_module and/or ngx\_stream\_lua\_module;
- [ngx\_devel\_kit](https://github.com/simpl/ngx_devel_kit) A prerequisite for some modules.







