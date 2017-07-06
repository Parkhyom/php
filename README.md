# php
PHP-7.0.20 &amp; solr 
#PHP日志位置
/app/logs/php-fpm.log
#如果你需要把日志映射到宿主机数据卷,如下
docker run -v /data/logs/:app/logs:rw imageid
