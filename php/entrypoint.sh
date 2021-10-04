#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
addgroup -S www
adduser -S -s /bin/bash -u $USER_ID -G www www
export HOME=/home/www

chown www:www /composer

exec su-exec root "$@"
