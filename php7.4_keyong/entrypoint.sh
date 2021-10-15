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
if [ -f "/data/wwwroot/ydd_modle/yidingdong-manager/start.sh" ]; then
    sh /data/wwwroot/ydd_modle/yidingdong-manager/start.sh    
fi

# /usr/local/php/sbin/php-fpm -F
/usr/local/php/sbin/php-fpm -D

# /usr/local/nginx/sbin/nginx -g
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
