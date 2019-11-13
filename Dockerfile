FROM alpine:3.10

ARG BUILD_CORES
ARG MEDIAINFO_VER=19.09
ARG RTORRENT_VER=v0.9.8
ARG LIBTORRENT_VER=v0.13.8
ARG LIBZEN_VER=0.4.37
ARG GEOIP_VER=1.1.1

ENV UID=1000 \
    GID=998 \
    WEBROOT=/ \
    PORT_RTORRENT=45000 \
    DHT_RTORRENT=off \
    DISABLE_PERM_DATA=false \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

LABEL Description="rutorrent based on alpine" \
      tags="latest" \
      maintainer="SckyzO <https://github.com/sckyzo>" \
      mediainfo_version="${MEDIAINFO_VER}" \
      libtorrent_version="${LIBTORRENT_VER}" \
      rtorrent_version="${RTORRENT_VER}" \
      libzen_version="${LIBZEN_VER}" 

RUN export BUILD_DEPS="build-base \
                        libtool \
                        automake \
                        autoconf \
                        wget \
                        libressl-dev \
                        ncurses-dev \
                        curl-dev \
                        zlib-dev \
                        libnl3-dev \
                        libsigc++-dev \
                        linux-headers \
	            		py-pip \
                        gcc \
                        g++ \
                        python-dev \
                        musl-dev \
                        libffi-dev \
                        openssl-dev" \
    ## Download Package
    && if [ "$RTORRENT_VER" == "0.9.6" ]; then CPPUNIT_VER="==1.13.2-r1"; fi \
    && apk upgrade --no-cache \
    && apk add -X http://dl-cdn.alpinelinux.org/alpine/v3.10/main --no-cache ${BUILD_DEPS} \
                ffmpeg \
                libnl3 \
                ca-certificates \
                gzip \
                zip \
                unrar \
                curl \
                c-ares \
                s6 \
                geoip \
                geoip-dev \
                su-exec \
                nginx \
                php7 \
                php7-fpm \
                php7-json \
                php7-opcache \
                php7-apcu \
                php7-mbstring \
                php7-ctype \
                php7-pear \
                php7-dev \
         		php7-sockets \
		        php7-phar \
                libressl \
                libzen \
                file \
                findutils \
                tar \
                xz \
                screen \
                findutils \
                bzip2 \
                bash \
                git \
                sox \
                python \
                cppunit-dev${CPPUNIT_VER} \
                cppunit${CPPUNIT_VER} \
    ## Download Sources
    && git clone https://github.com/esmil/mktorrent /tmp/mktorrent \
    && git clone https://github.com/mirror/xmlrpc-c.git /tmp/xmlrpc-c \
    && git clone -b ${LIBTORRENT_VER} https://github.com/rakshasa/libtorrent.git /tmp/libtorrent \
    && git clone -b ${RTORRENT_VER} https://github.com/rakshasa/rtorrent.git /tmp/rtorrent \
    && wget http://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VER}/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz -O /tmp/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    && wget http://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VER}/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz -O /tmp/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    #&& wget http://downloads.sourceforge.net/zenlib/libzen_${LIBZEN_VER}.tar.gz -O /tmp/libzen_${LIBZEN_VER}.tar.gz \
    && cd /tmp \
    #&& tar xzf libzen_${LIBZEN_VER}.tar.gz \
    && tar xzf MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    && tar xzf MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    ## Compile mktorrent
    && cd /tmp/mktorrent \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Compile Mediainfo
    && cd  /tmp/MediaInfo_DLL_GNU_FromSource \
    && ./SO_Compile.sh \
    && cd /tmp/MediaInfo_DLL_GNU_FromSource/ZenLib/Project/GNU/Library \
    && make install \
    && cd /tmp/MediaInfo_DLL_GNU_FromSource/MediaInfoLib/Project/GNU/Library \
    && make install \
    && cd /tmp/MediaInfo_CLI_GNU_FromSource \
    && ./CLI_Compile.sh \
    && cd /tmp/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI \
    && make install \
    ## Compile xmlrpc-c
    && cd /tmp/xmlrpc-c/stable \
    && ./configure \
    && make -j ${NB_CORES} \
    && make install \
    ## Compile libtorrent
    && cd /tmp/libtorrent \
    && ./autogen.sh \
    && ./configure \
        --disable-debug \
		--disable-instrumentation \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Compile rtorrent
    && cd /tmp/rtorrent \
    && ./autogen.sh \
    && ./configure \
        --enable-ipv6 \
		--disable-debug \
		--with-xmlrpc-c \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Install Rutorrent
    && mkdir -p /var/www \
    && git clone https://github.com/Novik/ruTorrent.git /var/www/html/rutorrent \
    && git clone https://github.com/nelu/rutorrent-thirdparty-plugins /tmp/rutorrent-thirdparty-plugins \
    && git clone https://github.com/mcrapet/plowshare /tmp/plowshare \
    && git clone https://github.com/xombiemp/rutorrentMobile.git /var/www/html/rutorrent/plugins/mobile \    
    && git clone https://github.com/Phlooo/ruTorrent-MaterialDesign.git /var/www/html/rutorrent/plugins/theme/themes/materialdesign \
    && git clone https://github.com/Micdu70/geoip2-rutorrent /var/www/html/rutorrent/plugins/geoip2 \
    && rm -rf /var/www/html/rutorrent/plugins/geoip \
    && sed -i "s/'mkdir'.*$/'mkdir',/" /tmp/rutorrent-thirdparty-plugins/filemanager/flm.class.php \
    && sed -i 's#.*/usr/bin/rar.*##' /tmp/rutorrent-thirdparty-plugins/filemanager/conf.php \
    && mv /tmp/rutorrent-thirdparty-plugins/* /var/www/html/rutorrent/plugins/ \
    && mv /var/www/html/rutorrent /var/www/html/torrent \
    ## Install plowshare
    && cd /tmp/plowshare \
    && make \
    ## Install geoip files
    && mkdir -p /usr/share/GeoIP \
    && cd /usr/share/GeoIP \
    && wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
    && wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
    && tar xzf GeoLite2-City.tar.gz \
    && tar xzf GeoLite2-Country.tar.gz \
    && rm -f *.tar.gz \
    && mv GeoLite2-*/*.mmdb . \
    && cp *.mmdb /var/www/html/torrent/plugins/geoip2/database/ \
    && pecl install geoip-${GEOIP_VER} \
    && chmod +x /usr/lib/php7/modules/geoip.so \
    ## Install cloudscraper 
    && pip install cloudscraper \
    ## cleanup
    && strip -s /usr/local/bin/rtorrent \
    && strip -s /usr/local/bin/mktorrent \
    && strip -s /usr/local/bin/mediainfo \
    && apk del -X http://dl-cdn.alpinelinux.org/alpine/v3.10/main --no-cache ${BUILD_DEPS} cppunit-dev \
    && rm -rf /tmp/*

COPY rootfs /
VOLUME /data /config
EXPOSE 8080
RUN chmod +x /usr/local/bin/startup

ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]

