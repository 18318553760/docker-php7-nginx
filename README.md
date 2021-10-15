# docker编译安装php7
前言：

php环境一直是php开发程序员头疼繁琐的事情，为了解决这个困难，docker使用一定程度上提高了程序的开发效率，下面是本人某些项目中部署php各个版本的部署文件，仅供大家参考，有bug请多多指教！！！

## 1、php7.3.8+nginx+swoole+redis

Dockfile文件

```
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

```

entrypoint.sh

```
#!/bin/sh
#########################################################################
# START
# File Name: entrypoint.sh
# Author: Mr.chen
# Email:  935859473@qq.com
# Created: 2021/09/09
#########################################################################

InstallPHPTools() {
	checkTools

    if [ -f "/usr/local/bin/composer" ]; then
    	echo  "已安装composer"     	
	    
    else
        echo "未安装composer"
      	wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer --no-check-certificate && \
    	chmod a+x /usr/local/bin/composer 
       
    fi  
	
    
}
# awk -F/ '{print $1}按空格分割
checkTools() {
  	res=$(yum list installed |grep net-tools |tail -1|awk  '{print $1}')
	if [[ $res != '' ]]; then
	    echo  "已安装net-tools" 	        
	    
    else
        yum install -y net-tools 
        echo  "未安装net-tools" 
       
    fi

    res=$(yum list installed |grep wget |tail -1|awk  '{print $1}')
	if [[ $res != '' ]]; then
	    echo  "已安装wget" 	        
	    
    else
        yum install -y wget 
        echo  "未安装wget" 
        
    fi
}
# 安装composer,net-tools文件
InstallPHPTools


# 启动项目文件
if [ -f "/data/wwwroot/test/start.sh" ]; then
    sh /data/wwwroot/test/start.sh    
fi

# /usr/local/php/sbin/php-fpm -F
/usr/local/php/sbin/php-fpm -D

# /usr/local/nginx/sbin/nginx -g
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf

```

项目文件，需要才启动，单纯的nginx+php不需要start.sh

start.sh

```
#!/bin/bash 
# 启动service
run_service() {
  	res=$(netstat -tunlp | grep 9502 |tail -1|awk  '{print $7}' |awk -F/ '{print $1}')
	if [[ $res != '' ]]; then
	        echo  "已启动" 
	        kill -9 $res	
	        echo "Process name=$name($res) kill!"
	        /usr/bin/nohup php /data/wwwroot/test/think run -H 0.0.0.0 -p 9502 > log.log 2>&1 &
	        return 1
	    else
	        echo  "未启动" 
	        /usr/bin/nohup php /data/wwwroot/test/think run -H 0.0.0.0 -p 9502  > log.log 2>&1 &
	        return 0
	    fi
}
run_service $1
echo '服务启动完毕.'

```



## 2、php7.4.21+nginx+swoole+redis

Dockfile文件

```
FROM centos:8
LABEL maintainer="Mr Chen <935859473@qq.com>"

ENV NGINX_VERSION 1.20.1
ENV PHP_VERSION 7.4.21
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
# install 编译安装gd
cd /home/nginx-php/php-$PHP_VERSION/ext/gd && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config --with-freetype --with-jpeg --enable-gd  && \
make && \
make install && \
echo "extension=gd.so" >> /usr/local/php/etc/php.ini && \
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

```

entrypoint.sh

```
#!/bin/sh
#########################################################################
# START
# File Name: entrypoint.sh
# Author: Mr.chen
# Email:  935859473@qq.com
# Created: 2021/09/09
#########################################################################

InstallPHPTools() {
	checkTools

    if [ -f "/usr/local/bin/composer" ]; then
    	echo  "已安装composer"     	
	    
    else
        echo "未安装composer"
      	wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer --no-check-certificate && \
    	chmod a+x /usr/local/bin/composer 
       
    fi  
	
    
}
# awk -F/ '{print $1}按空格分割
checkTools() {
  	res=$(yum list installed |grep net-tools |tail -1|awk  '{print $1}')
	if [[ $res != '' ]]; then
	    echo  "已安装net-tools" 	        
	    
    else
        yum install -y net-tools 
        echo  "未安装net-tools" 
       
    fi

    res=$(yum list installed |grep wget |tail -1|awk  '{print $1}')
	if [[ $res != '' ]]; then
	    echo  "已安装wget" 	        
	    
    else
        yum install -y wget 
        echo  "未安装wget" 
        
    fi
}
# 安装composer,net-tools文件
InstallPHPTools


# 启动项目文件
if [ -f "/data/wwwroot/test/start.sh" ]; then
    sh /data/wwwroot/test/start.sh    
fi

# /usr/local/php/sbin/php-fpm -F
/usr/local/php/sbin/php-fpm -D

# /usr/local/nginx/sbin/nginx -g
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf

```

项目文件，需要才启动，单纯的nginx+php不需要start.sh

start.sh

```
#!/bin/bash 
# 启动service
run_service() {
  	res=$(netstat -tunlp | grep 9502 |tail -1|awk  '{print $7}' |awk -F/ '{print $1}')
	if [[ $res != '' ]]; then
	        echo  "已启动" 
	        kill -9 $res	
	        echo "Process name=$name($res) kill!"
	        /usr/bin/nohup php /data/wwwroot/test/think run -H 0.0.0.0 -p 9502 > log.log 2>&1 &
	        return 1
	    else
	        echo  "未启动" 
	        /usr/bin/nohup php /data/wwwroot/test/think run -H 0.0.0.0 -p 9502  > log.log 2>&1 &
	        return 0
	    fi
}
run_service $1
echo '服务启动完毕.'

```

# 部署：

windows下文件修改的dockerfile格式需要修改成unix,否则报错，包括所有的sh文件nginx-php下extension也有sh文件，根目录下的entrypoint.sh也需要查看文件格式
linux下运行vim,查看格式 :set ff?

```
:set ff=unix
wq!
```

打包程序，有可能会下载文件失败，失败后需要重试

```
docker build . -t php7.3:v1
```

运行：

```
cd /example && \
docker run -p 80:9502  \
-v $(pwd)/wwwroot:/data/wwwroot \
-v $(pwd)/wwwlogs:/data/wwwlogs \
-v $(pwd)/vhost:/data/server/nginx/vhost \
-v $(pwd)/ssl:/data/server/nginx/ssl \
-v $(pwd)/ini:/data/server/php/ini \
-v $(pwd)/extension:/data/server/php/extension \
-d  php7.3:v1;
```

查看容器日记：docker logs 容器id

进入容器：

```
docker exec -it 容器id /bin/bash
```

查看php扩展

```
php-m
```

查看php配置文件路径

```
php -i |grep php.ini
```

项目可能需要如下配置

```
swoole.use_shortname=off
zlib.output_compression = On
```

导出镜像

```
docker save php7.3:v1 > php7.3.tar
```

查看端口

```
netstat -tunlp | grep 9502   
#kill -9 pid
```

防火墙设置：

```
firewall-cmd --zone=public --add-port=80/tcp --permanent
systemctl restart firewalld.service
firewall-cmd --list-ports
```

nginx配置

```
server {
    listen 80;
    server_name localhost;
    root   /data/wwwroot/test;
    index  index.php index.html index.htm;

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    # error_page   500 502 503 504  /50x.html;
    # location = /50x.html {
    #     root   html;
    # }
    
    location / {
        if (!-e $request_filename) {
            rewrite ^(.*)$ /index.php?s=$1 last;
            break;
        }
    }

   location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
    
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
        expires 30d;
        access_log off;
    }

    location ~ .*\.(js|css)?$ {
        expires 7d;
        access_log off;
    }

    location ~ /\.(ht|git|vscode|idea) {
        deny all;
    }

    # https
    # listen 443 ssl http2;
    # ssl_certificate ssl/localhost.crt;
    # ssl_certificate_key ssl/localhost.key;
    # ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    # ssl_prefer_server_ciphers on;
    # ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    # keepalive_timeout 70;
    # ssl_session_cache shared:SSL:10m;
    # ssl_session_timeout 10m;    
}


```

注意：

php7.3通过--with-gd包含gd库，无需自动安装

php7.4版本默认不包含gd库，需要自动安装，参考php7.4安装gd扩展：https://www.wangjia.net/bo-blog/php-7-4-9-with-gd-extension/

参考地址：https://github.com/18318553760/docker-php7-nginx.git






