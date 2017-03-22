version: "2"
services:
  web:
    restart: always
    image : nnynn/dkgr-nginx:latest
#    image : dkgr-nginx
#    build:
#      context : ./nginx
#      dockerfile: Dockerfile
    #ports:
       #HTTP_PORT#
       #HTTPS_PORT#
    volumes:
      - .ssh:/home/www/.ssh
      #WWW_VOLUME#
      #HTPASSWD#
      #SHARED_ACCOUNT_VOLUME#
    environment:
      - VIRTUAL_PORT=80
      #LETSENCRYPT_HOST#
      #LETSENCRYPT_EMAIL#
      #VIRTUAL_HOST#
      #LOCAL_USER_ID#
    links:
      - php
    networks:
      - www
  php:
    restart: always
    image : nnynn/dkgr-php:latest
#    image : dkgr-php:last
#    build:
#      context : ./php
#      dockerfile: Dockerfile
    environment:
      - DEBUG=0
      #LOCAL_USER_ID#
    volumes:
      #WWW_VOLUME#
      - .ssh:/home/www/.ssh
      #SHARED_ACCOUNT_VOLUME#
    networks:
      - www
networks:
  www:
    external : true
