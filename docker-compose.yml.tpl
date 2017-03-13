version: "2"
services:
  web:
    restart: always
    image : docker-grav-nginx
    build:
      context : ./nginx
      dockerfile: Dockerfile
    #ports:
       #HTTP_PORT#
       #HTTPS_PORT#
    volumes:
      - ./www:/www
    environment:
      - VIRTUAL_PORT=80
      #VIRTUAL_HOST#
      #LOCAL_USER_ID#
    links:
      - php
    networks:
      - www
  php:
    restart: always
    image : docker-grav-php
    build:
      context : ./php-fpm
      dockerfile: Dockerfile
    environment:
      - DEBUG=0
      #LOCAL_USER_ID#
    volumes:
      - ./www:/www
    networks:
      - www
networks:
  www:
    external : true
