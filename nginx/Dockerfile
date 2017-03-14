FROM nginx:1.11-alpine

RUN apk --update add \
        bash \
        sed \
        su-exec

RUN sed -i \
        -e 's|user  nginx;|user www;|' \
    /etc/nginx/nginx.conf && cat /etc/nginx/nginx.conf

RUN rm -Rf /etc/nginx/conf.d/default.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80 443
