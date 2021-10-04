FROM php:8-fpm-alpine

RUN apk --update add \
        bash \
        sed \
        su-exec\
        curl \
        openssl \
        openssh-client \
        git \
        libpng\
        libpng-dev\
        libzip-dev \
        zip \
    && rm -rf /var/cache/apk/*

RUN docker-php-ext-install gd posix zip

EXPOSE 9000

RUN ls -al /usr/local/etc/php

RUN echo "listen = 9000" >> /usr/local/etc/php-fpm.conf
RUN echo "user = www" >> /usr/local/etc/php-fpm.conf
RUN echo "group = www" >> /usr/local/etc/php-fpm.conf 
RUN echo "listen.owner = www" >> /usr/local/etc/php-fpm.conf
RUN echo "listen.group = www" >> /usr/local/etc/php-fpm.conf


# Note that the value could be 0 to disable the limit
RUN sed -i \
      -e 's|;extension=|extension=|' \
      -e 's|post_max_size = 8M|post_max_size = 1000M|' \
      -e 's|upload_max_filesize = 2M|upload_max_filesize = 1000M|' \
      /usr/local/etc/php/php.ini-production && (cat /usr/local/etc/php/php.ini-production |grep post_max_size && cat /usr/local/etc/php/php.ini-production |grep upload_max_filesize)

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
