FROM tekintian/alpine:3.8

LABEL maintainer="TekinTian <tekintian@gmail.com>"

# http://nginx.org/
ENV NGINX_VERSION 1.16.1
# https://github.com/nbs-system/naxsi
# https://github.com/nbs-system/naxsi/archive/0.56.tar.gz
ENV NAXSI_VERSION 0.56
# https://luajit.org/download.html 官方已经好几年没有更新了，换成 openresty的版本
# https://github.com/openresty/luajit2/releases
# https://github.com/openresty/luajit2/archive/v$LUAJIT_VERSION.tar.gz
ENV LUAJIT_VERSION 2.1-20200102
# https://github.com/simplresty/ngx_devel_kit
ENV NDK_VERSION 0.3.1
# https://github.com/openresty/lua-nginx-module/releases
ENV LUA_VERSION 0.10.16rc5
# https://github.com/openresty/lua-cjson/releases
ENV LUA_CJSON_VERSION 2.1.0.8rc1
# https://github.com/ledgetech/lua-resty-http/releases
ENV LUA_HTTP_VERSION 0.14
# https://github.com/tekintian/lua-resty-core/
# COPY assets/lua-rest-core/Makefile /tmp/lrc_Makefile
# COPY src/lua-cjson-2.1.0.7 /tmp/lua-cjson-2.1.0.7
ENV LOCAL_URL="http://192.168.2.8/nginx"

RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	&& CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=www-data \
		--group=www-data \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
		--add-module=/usr/src/naxsi-$NAXSI_VERSION/naxsi_src \
		--with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib" \
        --add-dynamic-module=/usr/src/ngx_devel_kit-$NDK_VERSION \
        --add-dynamic-module=/usr/src/lua-nginx-module-$LUA_VERSION \
        --add-dynamic-module=/usr/src/set-misc-nginx-module-master \
        --add-dynamic-module=/usr/src/encrypted-session-nginx-module-master \
        --add-dynamic-module=/usr/src/echo-nginx-module-master \
	" \
	&& addgroup -g 82 -S www-data \
	&& adduser -u 82 -D -S -h /var/cache/nginx -s /sbin/nologin -G www-data www-data \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg1 \
		libxslt-dev \
		gd-dev \
		geoip-dev \
		wget \
		unzip \
	\
	&& cd /tmp/ \
	&& wget https://tekintian.coding.net/p/alpine-nginx/d/alpine-nginx/git/raw/master/src_conf.zip -O src_conf.zip \
	&& unzip src_conf.zip \
	&& mv src_conf/* /tmp \
	\
	&& wget $LOCAL_URL/nginx-$NGINX_VERSION.tar.gz \
	&& wget $LOCAL_URL/naxsi-$NAXSI_VERSION.tar.gz \
	&& wget $LOCAL_URL/ngx_devel_kit-$NDK_VERSION.tar.gz \
	&& wget $LOCAL_URL/luajit2-$LUAJIT_VERSION.tar.gz \
	&& wget $LOCAL_URL/lua-nginx-module-$LUA_VERSION.tar.gz \
	&& wget $LOCAL_URL/lua-resty-core-master.tar.gz \
	&& wget $LOCAL_URL/set-misc-nginx-module-master.tar.gz \
	&& wget $LOCAL_URL/encrypted-session-nginx-module-master.tar.gz \
	&& wget $LOCAL_URL/lua-resty-cookie-master.tar.gz \
	&& wget $LOCAL_URL/echo-nginx-module-master.tar.gz \
	&& wget $LOCAL_URL/lua-cjson-$LUA_CJSON_VERSION.tar.gz \
	&& wget $LOCAL_URL/lua-resty-http-$LUA_HTTP_VERSION.tar.gz \
	\
	&& wget $LOCAL_URL/lua-resty-lrucache-master.tar.gz \
	&& wget $LOCAL_URL/lua-resty-redis-master.tar.gz \
	&& wget $LOCAL_URL/lua-resty-mysql-master.tar.gz \
	&& wget $LOCAL_URL/lua-resty-logger-socket-master.tar.gz \
	&& wget $LOCAL_URL/lua-resty-string-master.tar.gz \
	\
	# && export GNUPGHOME="$(mktemp -d)" \
	# && found=''; \
	# for server in \
	# 	ha.pool.sks-keyservers.net \
	# 	hkp://keyserver.ubuntu.com:80 \
	# 	hkp://p80.pool.sks-keyservers.net:80 \
	# 	pgp.mit.edu \
	# ; do \
	# 	echo "Fetching GPG key $GPG_KEYS from $server"; \
	# 	gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	# done; \
	# test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	# gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	# && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx-$NGINX_VERSION.tar.gz \
	&& tar -zxC /usr/src -f naxsi-$NAXSI_VERSION.tar.gz \
	&& tar -zxC /usr/src -f luajit2-$LUAJIT_VERSION.tar.gz \
	&& tar -zxC /usr/src -f ngx_devel_kit-$NDK_VERSION.tar.gz \
	&& tar -zxC /usr/src -f lua-nginx-module-$LUA_VERSION.tar.gz \
	&& tar -zxC /usr/src -f lua-resty-core-master.tar.gz \
	&& tar -zxC /usr/src -f set-misc-nginx-module-master.tar.gz \
	&& tar -zxC /usr/src -f encrypted-session-nginx-module-master.tar.gz \
	&& tar -zxC /usr/src -f lua-resty-cookie-master.tar.gz \
	&& tar -zxC /usr/src -f echo-nginx-module-master.tar.gz \
	&& tar -zxC /usr/src -f lua-cjson-$LUA_CJSON_VERSION.tar.gz \
	&& tar -zxC /usr/src -f lua-resty-http-$LUA_HTTP_VERSION.tar.gz \
	\
	&& tar -zxC /usr/src -f lua-resty-lrucache-master.tar.gz \
	&& tar -zxC /usr/src -f lua-resty-redis-master.tar.gz \
	&& tar -zxC /usr/src -f lua-resty-mysql-master.tar.gz \
	&& tar -zxC /usr/src -f lua-resty-logger-socket-master.tar.gz \
	&& tar -zxC /usr/src -f lua-resty-string-master.tar.gz \
	# LuaJIT 2.1.x install \
	&& cd /usr/src/luajit2-$LUAJIT_VERSION \
	&& make install PREFIX=/usr/local/luajit \
	&& export LUAJIT_LIB=/usr/local/luajit/lib \
	&& export LUAJIT_INC=/usr/local/luajit/include/luajit-2.1 \
	&& ln -sf /usr/local/luajit/bin/luajit-$LUAJIT_VERSION /usr/local/luajit/bin/luajit \
	# lua-resty-core install \
	&& cd /usr/src/lua-resty-core-master \
	&& mv Makefile Makefile.bk \
	&& mv /tmp/lrc_Makefile /usr/src/lua-resty-core-master/Makefile \
	&& make && make install \
	# lua-json install more https://www.kyne.com.au/~mark/software/lua-cjson-manual.html#_installation \
	&& cd /usr/src/lua-cjson-$LUA_CJSON_VERSION \
	# 修正编译路径
	&& sed -i "s@^PREFIX =            /usr/local@PREFIX = /usr/local/luajit@" ./Makefile \
	&& sed -i "s@^LUA_INCLUDE_DIR ?=   \$(PREFIX)/include@LUA_INCLUDE_DIR ?=   \$(PREFIX)/include/luajit-2.1@" ./Makefile \
	&& make && make install \
	# Lua resty core install \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /var/www/public/ \
	&& install -m644 html/index.html /var/www/public/ \
	&& install -m644 html/50x.html /var/www/public/ \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& cp /usr/src/naxsi-$NAXSI_VERSION/naxsi_config/naxsi_core.rules /etc/nginx/naxsi_core.rules \
	&& cp -a -r /usr/src/lua-resty-lrucache-master/lib/resty/*  /etc/nginx/lua/lib/$LUA_VERSION/resty/ \
	&& cp -a -r /usr/src/lua-resty-redis-master/lib/resty/*  /etc/nginx/lua/lib/$LUA_VERSION/resty/ \
	&& cp -a -r /usr/src/lua-resty-mysql-master/lib/resty/*  /etc/nginx/lua/lib/$LUA_VERSION/resty/ \
	&& cp -a -r /usr/src/lua-resty-logger-socket-master/lib/resty/*  /etc/nginx/lua/lib/$LUA_VERSION/resty/ \
	&& cp -a -r /usr/src/lua-resty-string-master/lib/resty/*  /etc/nginx/lua/lib/$LUA_VERSION/resty/ \
	&& cp -a -r /usr/src/lua-resty-http-$LUA_HTTP_VERSION/lib/resty/*  /etc/nginx/lua/lib/$LUA_VERSION/resty/ \
	&& cp -a -r /usr/src/lua-resty-cookie-master/lib/resty/*  /etc/nginx/lua/lib/$LUA_VERSION/resty/ \
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	# diy conf file
	#backup default nginx.conf
	&& mv /etc/nginx/nginx.conf /etc/nginx/nginx_conf.default \
	&& cd /tmp/ \
	&& mv public/index.html /var/www/public/index.html \
	&& mv nginx.lua.conf /etc/nginx/nginx.conf \
	&& mv naxsi.rules /etc/nginx/conf.d/naxsi.rules \
	&& mv fastcgi.conf /etc/nginx/fastcgi.conf \
	&& mv nginx.lua.default.conf /etc/nginx/conf.d/default.conf \
	# diy conf file end
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# 替换默认的NGINX配置中的lua路径
	&& sed -i "s#/etc/nginx/lua/lib/0.10.15#/etc/nginx/lua/lib/${LUA_VERSION}#g" /etc/nginx/nginx.conf \
	# Bring in tzdata so users could set the timezones through the environment
	# variables
	# && apk add --no-cache tzdata \
	# \
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
	&& rm -rf /tmp/* \
	&& rm -rf /usr/src/*

WORKDIR /var/www

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

