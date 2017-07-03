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
	bzip2 \
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
	libpng-devel \
	gcc \
	openssl-devel

ENV PHP_DIR /usr/local/php \
    PHP_INI_DIR /etc \
    PHP_VERSION php-7.0.20 \
    PHP_URL http://cn2.php.net/distributions/php-7.0.20.tar.gz \
    MCRYPT_URL wget ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/attic/libmcrypt/libmcrypt-2.5.7.tar.gz

RUN set -xe ; \
	CONFIGURE_PAR=" \
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
	--without-pear" \
	; \
	yum install -y $PHPIZE_DEPS wget curl net-tools; \
	\
	wget $PHP_URL; \
	wget $MCRYPT_URL; \
	tar -zxvf libmcrypt-2.5.7.tar.gz && cd libmcrypt-2.5.7 && ./config --prefix=/usr/local; \
	make && make install && cd; \
	tar -zxvf php-7.0.20.tar.gz && cd php-7.0.20; \
	sed -i '6d' /root/.bashrc && su -c "cp -frp /usr/lib64/libldap* /usr/lib/"; \
	echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf && ldconfig; \
	./configure $CONFIGURE_PAR; \
	sed -i '/^EXTRA_LIBS.*$/s//& -llber/g' Makefile; \
	make && make install; \
	\
	##re-configure PHP_INI_FILE && PHP_CONF_FILE
	\
	cd $PHP_DIR/etc; \
	cp php-fpm.conf.default php-fpm.conf; \
	cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	echo "extension=solr.so" >> /etc/php.ini \
	\
	#delete temp-configuration file
	yum autoremove -y $PHPIZE_DEPS && yum clean all; \
	cd && cd php-7.0.20 && make distclean; \
	cd && cd libmcrypt-2.5.7 && make distclean; \
	cd && rm -rf * \
	\

EXPOSE 9000
CMD ["/usr/local/php/sbin/php-fpm"]
