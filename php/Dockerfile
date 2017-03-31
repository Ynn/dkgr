FROM alpine:3.5

RUN apk --update add \
        bash \
        sed \
        su-exec\
        curl \
        openssl \
        openssh-client \
        git \
        php7 \
        php7-bcmath \
        php7-dom \
        php7-ctype \
        php7-curl \
        php7-fpm \
        php7-gd \
        php7-iconv \
        php7-intl \
        php7-json \
        php7-mbstring \
        php7-mcrypt \
        php7-mysqlnd \
        php7-opcache \
        php7-openssl \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-phar \
        php7-posix \
        php7-session \
        php7-soap \
        php7-xml \
        php7-zip \
    && rm -rf /var/cache/apk/*

RUN ln -s /usr/bin/php7 /usr/bin/php

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"


EXPOSE 9000

RUN sed -i \
        -e 's|listen = 127.0.0.1:9000|listen = 9000|' \
        -e 's|user = nobody|user = www|' \
        -e 's|group = nobody|group = www|' \
       -e 's|;listen.owner = nobody|listen.owner = www|' \
       -e 's|;listen.group = nobody|listen.group = www|' \
   /etc/php7/php-fpm.d/www.conf && cat /etc/php7/php-fpm.d/www.conf

# Note that the value could be 0 to disable the limit
RUN sed -i \
      -e 's|post_max_size = 8M|post_max_size = 1000M|' \
      -e 's|upload_max_filesize = 2M|upload_max_filesize = 1000M|' \
      /etc/php7/php.ini

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm7", "-F"]
