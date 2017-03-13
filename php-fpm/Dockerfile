FROM phusion/baseimage:0.9.19

RUN apt-get update && apt-get -y --no-install-recommends install \
    ca-certificates \
    curl

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

#Install core packages
RUN apt-get update -q
RUN apt-get upgrade -y -q
RUN apt-get install -y -q php php-cli php-fpm php-gd php-curl php-apcu php-xml php-mbstring php-zip ca-certificates git-core
RUN apt-get clean -q && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i \
        -e 's|listen = /run/php/php7.0-fpm.sock|listen = 9000|' \
        -e 's|user = www-data|user = www|' \
        -e 's|group = www-data|group = www|' \
       -e 's|listen.owner = www-data|listen.owner = www|' \
       -e 's|listen.group = www-data|listen.group = www|' \
   /etc/php/7.0/fpm/pool.d/www.conf
RUN cat /etc/php/7.0/fpm/pool.d/www.conf

#Setup Php service
RUN mkdir -p /run/php/
RUN touch /run/php/php7.0-fpm.sock
RUN mkdir -p /etc/service/php-fpm
RUN touch /etc/service/php-fpm/run
RUN chmod +x /etc/service/php-fpm/run
RUN echo '#!/bin/bash \n\
   exec /usr/sbin/php-fpm7.0 -F' >> /etc/service/php-fpm/run


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/etc/service/php-fpm/run"]

#Public ports
EXPOSE 9000
