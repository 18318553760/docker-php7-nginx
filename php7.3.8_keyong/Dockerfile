FROM centos:8
LABEL maintainer="Mr Chen <935859473@qq.com>"

ENV NGINX_VERSION 1.20.1
ENV PHP_VERSION 7.3.8
ENV SWOOLE_VERSION 4.5.1
ENV REDIS_VERSION 5.0.2

ENV PRO_SERVER_PATH=/data/server
ENV NGX_WWW_ROOT=/data/wwwroot
ENV NGX_LOG_ROOT=/data/wwwlogs
ENV PHP_EXTENSION_SH_PATH=/data/server/php/extension
ENV PHP_EXTENSION_INI_PATH=/data/server/php/ini

## mkdir folders
RUN mkdir -p /data/{wwwroot,wwwlogs,server/php/ini,server/php/extension,}
# ADD ruanjian/onig-6.9.5-rev1.tar.gz /
RUN dnf install -y epel-release && \
#
## install libraries
set -x && \
dnf install -y \
gcc gcc-c++ wget vim make cmake automake autoconf kernel-devel ncurses-devel net-tools \
libxml2-devel pcre-devel openssl openssl-devel curl-devel libjpeg-devel \
libpng-devel pcre-devel libtool-libs freetype-devel gd zlib-devel file \
patch mlocate flex diffutils readline-devel glibc-devel \
glib2-devel bzip2-devel gettext-devel libcap-devel libmcrypt-devel gmp-devel \
libxslt-devel git libevent libevent-devel perl-ExtUtils-MakeMaker sqlite-devel  xz && \
#
# install composer
wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer --no-check-certificate && \
chmod a+x /usr/local/bin/composer && \
#
# make temp folder
mkdir -p /home/nginx-php && cd $_ && \
# 
# install nginx
curl -Lk https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
# curl -Lk http://172.17.0.1/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
cd /home/nginx-php/nginx-$NGINX_VERSION && \
./configure --prefix=/usr/local/nginx \
--user=www --group=www \
--error-log-path=${NGX_LOG_ROOT}/nginx_error.log \
--http-log-path=${NGX_LOG_ROOT}/nginx_access.log \
--pid-path=/var/run/nginx.pid \
--with-pcre \
--with-http_ssl_module \
--with-http_v2_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--with-http_gzip_static_module && \
make && make install && \
# add user
useradd -r -s /sbin/nologin -d ${NGX_WWW_ROOT} -m -k no www && \
# ln nginx
ln -s /usr/local/nginx/conf ${PRO_SERVER_PATH}/nginx && \
#
# install oniguruma php ext
curl -Lk https://github.com/kkos/oniguruma/releases/download/v6.9.5_rev1/onig-6.9.5-rev1.tar.gz | gunzip | tar x -C /home/nginx-php && \
# curl -Lk http://172.17.0.1/onig-6.9.5-rev1.tar.gz | gunzip | tar x -C /home/nginx-php && \
# 使用本地包,ADD ruanjian/onig-6.9.5-rev1.tar.gz /在前面，因为这是一连串的语句,上面带&&
# 
# cd / &&  tar x -C /home/nginx-php onig-6.9.5-rev1.tar.gz && \
cd /home/nginx-php/onig-6.9.5 && \
./configure --prefix=/usr && \
make && make install && \
#
# install php
curl -Lk https://php.net/distributions/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
# curl -Lk http://172.17.0.1/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
cd /home/nginx-php/php-$PHP_VERSION && \  
./configure --prefix=/usr/local/php \
--enable-fpm \
--with-config-file-path=/usr/local/php/etc \
--with-config-file-scan-dir=${PHP_EXTENSION_INI_PATH} \
--with-fpm-user=www \
--with-fpm-group=www \
--with-libxml-dir --with-openssl \
--with-mysqli \
--enable-bcmath \
--with-bz2 \
--enable-calendar \
--with-curl \
--enable-exif \
--with-pcre-dir \
--enable-ftp \
--with-openssl-dir \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-freetype-dir \
--enable-gd-jis-conv \
--with-gettext \
--with-gmp \
--with-mhash \
--enable-mbstring \
--with-onig \
--with-pdo-mysql \
--with-readline \
--enable-shmop \
--enable-soap \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-wddx \
--with-xmlrpc \
--with-xsl \
--with-pear \
--enable-shared \
--enable-inline-optimization \
--disable-debug \
--enable-xml \
--with-sqlite3 \
--with-iconv \
--with-cdb \
--enable-dom \
--enable-fileinfo \
--enable-filter \
--enable-json \
--enable-mbregex \
--enable-mbregex-backtrack \
--enable-pdo \
--with-pdo-sqlite \
--enable-session \
--enable-simplexml \
--enable-opcache \
--enable-mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-maintainer-zts && \
make && make install && \
#
# install php-fpm
cd /home/nginx-php/php-$PHP_VERSION && \
cp php.ini-production /usr/local/php/etc/php.ini && \
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf && \
# php command support
ln -s /usr/local/php/bin/* /bin/ && \
#
# install 编译安装gd,php7.4才需要，--with-gd自动安装
# cd /home/nginx-php/php-$PHP_VERSION/ext/gd && \
# /usr/local/php/bin/phpize && \
# ./configure --with-php-config=/usr/local/php/bin/php-config --with-freetype --with-jpeg --enable-gd  && \
# make && \
# make install && \
# echo "extension=gd.so" >> /usr/local/php/etc/php.ini && \
#
# install swoole
mkdir /home/extension && \
# curl -Lk https://github.com/swoole/swoole-src/archive/v$SWOOLE_VERSION.tar.gz | gunzip | tar x -C /home/extension && \
curl -Lk https://codeload.github.com/swoole/swoole-src/tar.gz/refs/tags/v$SWOOLE_VERSION | gunzip | tar x -C /home/extension && \
cd /home/extension/swoole-src-$SWOOLE_VERSION && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && \
make install && \
echo "extension=swoole.so" >> /usr/local/php/etc/php.ini && \
# install redis
curl -Lk  http://pecl.php.net/get/redis-$REDIS_VERSION.tgz | gunzip | tar x -C /home/extension && \
cd /home/extension/redis-$REDIS_VERSION && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && \
make install && \
echo "extension=redis.so" >> /usr/local/php/etc/php.ini && \
rm -rf /home/extension && \
# remove temp folder
rm -rf /home/nginx-php && \
#
# clean os
dnf remove -y gcc \
gcc-c++ \
autoconf \
automake \
libtool \
make \
cmake && \
dnf clean all && \
# dnf remove epel-release -y && \
# remove cache
rm -rf /tmp/* /var/cache/{yum,ldconfig} /etc/my.cnf{,.d} && \
mkdir -p --mode=0755 /var/cache/{yum,ldconfig} && \
find /var/log -type f -delete

VOLUME ["/data/wwwroot", "/data/wwwlogs", "/data/server/php/ini", "/data/server/php/extension", "/data/server/nginx"]

# NGINX
ADD nginx.conf /usr/local/nginx/conf/
ADD vhost /usr/local/nginx/conf/vhost
ADD www ${NGX_WWW_ROOT}

# Start
ADD entrypoint.sh /

RUN chown -R www:www ${NGX_WWW_ROOT} && \
chmod +x /entrypoint.sh

# Set port
EXPOSE 80 443

# CMD ["/usr/local/php/sbin/php-fpm", "-F", "daemon off;"]
# CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]

# Start it
ENTRYPOINT ["/entrypoint.sh"]
