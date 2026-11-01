#!/bin/sh
set -eu

sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN_NAME}/" /etc/nginx/sites-available/default
mkdir -p /etc/nginx/ssl
if [ ! -s /etc/nginx/ssl/inception.crt ] || [ ! -s /etc/nginx/ssl/inception.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/inception.key -out /etc/nginx/ssl/inception.crt -subj "/CN=${DOMAIN_NAME}"
fi

exec nginx -g 'daemon off;'
