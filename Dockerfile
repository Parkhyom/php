FROM centos

ENV PHPIZE_DEPS \
		libxml2-devel \
		openssl \
		libssl-devel \
		curl \
		libcurl4-gnutls-devel \
		libjpeg-devel \
		libpng12-dein \
		vel \
		libfreetype6 \
		libfreetype6-devel \
		libmcrypt4 \
		libmcrypt-devel \
		php-mcrypt \ 
    		libmcrypt \
		libmcrypt-devel \
		gd \
		build-essential \
		autoconf \
		bzip2\
		bzip2-devel \
		openldap \
		openldap-devel \
		aspell \
		aspell-devel \
		readline \
		readline-devel \
		libxslt \
		libxslt-devel \
		pcre \
		pcre-devel \
		freetype \
		freetype-devel \
		gmp-devel \
		curl-devel \
		libpng-devel
    
RUN yum install -y $PHPIZE_DEPS

ENV PHP_VERSION 7.0.20 \
    PHP_URL http://cn2.php.net/distributions/php-7.0.20.tar.gz \
    PHP_DIR /usr/local/php \
    PHP_INI_DIR /etc 
  
RUN set -xe; \
        CONFIGURE_FILE=' \
		--prefix=/usr/local/php \
		--exec-prefix=/usr/local/php \
		--bindir=/usr/local/php/bin \
		--sbindir=/usr/local/php/sbin \
		--includedir=/usr/local/php/include \
		--libdir=/usr/local/php/lib/php \
		--mandir=/usr/local/php/php/man \
		--with-config-file-path=/usr/local/php/etc \
		--with-mysql-sock=/var/run/mysql/mysql.sock \
		--with-mcrypt=/usr/include \
		--with-mhash \
		--enable-opcache \
		--enable-mysqlnd \
		--with-mysqli=shared,mysqlnd \
		--with-pdo-mysql=shared,mysqlnd \
		--enable-fpm \
		--enable-static \
		--enable-inline-optimization \
		--enable-sockets \
		--enable-pdo \
		--enable-exif \
		--enable-wddx \
		--enable-zip \
		--enable-calendar \
		--enable-dba \
		--enable-gd-jis-conv \
		--enable-sysvmsg \
		--enable-sysvshm \
		--with-gd \
		--with-iconv \
		--with-openssl \
		--with-zlib \
		--with-gmp \
		--with-pdo-sqlite \
		--enable-bcmath \
		--enable-soap \
		--with-xmlrpc \
		--with-pspell \
		--with-pcre-regex \
		--enable-mbstring \
		--enable-shared \
		--with-curl \
		--with-bz2 \
		--with-xsl \
		--enable-xml \
		--enable-ftp \
		--with-mcrypt \
		--with-mhash \
		--enable-shmop \
		--enable-sysvsem \
		--enable-mbregex \
		--enable-gd-native-ttf \
		--enable-pcntl \
		--enable-session \
		--enable-fileinfo \
		--with-gettext \
		--with-freetype-dir \
		--with-jpeg-dir \
		--with-png-dir \
		--with-readline \
		--with-ldap \
		--with-pear \
		--disable-ipv6 \
		--disable-debug \
		--disable-maintainer-zts \
		--disable-rpath \
		--without-gdbm \
		--without-pear \
        '; \
        \
        wget -O php.tar.gz $PHP_URL; \
        tar -zxvf php.tar.gz && cd php; \
        sed -i '6d' /root/.bashrc && su && cp -frp /usr/lib64/libldap* /usr/lib/ && exit; \
        ./configure $CONFIGURE_FILE; \
        sed -i '/^EXTRA_LIBS.*$/s//& -llber/g' Makefile; \
        make && make install; \
        make distclean; \
        cd && rm -rf php; \
        \
        #php-solr plugin installation as follow
        \
        wget -O solr.tgz http://pecl.php.net/get/solr-2.4.0.tgz; \
        tar -zxvf solr.tgz && cd solr && /usr/local/php/bin/phpize; \
        ./configure --with-php-config=/usr/local/php/bin/php-config; \
        make && make install; \
        make distclean; \
        cd && rm -rf solr; \
        \
        yum autoremove -y $PHPIZE_DEPS && yum clean all; \
        \
        #re-configure PHP_INI_FILE && PHP_CONF_FILE
        cd $PHP_DIR/etc; \
        cp php-fpm.conf.default php-fpm.conf; \
        cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
        echo "extension=solr.so" >> /etc/php.ini; \
        \

EXPOSE 9000
CMD ["/usr/local/php/sbin/php-fpm"]
