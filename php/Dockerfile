FROM alpine:3.5

RUN apk --update add \
        bash \
        sed \
        su-exec\
        curl \
        openssl \
        openssh-client \
        git \
        php5 \
        php5-bcmath \
        php5-dom \
        php5-ctype \
        php5-curl \
        php5-fpm \
        php5-zlib \
        php5-gd \
        php5-iconv \
        php5-intl \
        php5-json \
#        php5-mbstring \
        php5-mcrypt \
#        php5-mysqlnd \
        php5-opcache \
        php5-openssl \
        php5-pdo \
        php5-pdo_mysql \
        php5-pdo_pgsql \
        php5-pdo_sqlite \
        php5-phar \
        php5-posix \
#        php5-session \
        php5-soap \
        php5-xml \
        php5-zip \
    && rm -rf /var/cache/apk/*

#RUN ln -s /usr/bin/php5 /usr/bin/php

EXPOSE 9000

RUN ls -al /etc/php5/conf.d

RUN sed -i \
        -e 's|listen = 127.0.0.1:9000|listen = 9000|' \
        -e 's|user = nobody|user = www|' \
        -e 's|group = nobody|group = www|' \
       -e 's|;listen.owner = nobody|listen.owner = www|' \
       -e 's|;listen.group = nobody|listen.group = www|' \
   /etc/php5/php-fpm.conf && (cat /etc/php5/php-fpm.conf |grep listen && cat  /etc/php5/php-fpm.conf |grep 'group =' && cat  /etc/php5/php-fpm.conf |grep 'user =')

# Note that the value could be 0 to disable the limit
RUN sed -i \
      -e 's|post_max_size = 8M|post_max_size = 1000M|' \
      -e 's|upload_max_filesize = 2M|upload_max_filesize = 1000M|' \
      /etc/php5/php.ini && (cat /etc/php5/php.ini |grep post_max_size && cat /etc/php5/php.ini |grep upload_max_filesize)

RUN mkdir /composer

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --install-dir=/usr/bin --filename=composer


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]
