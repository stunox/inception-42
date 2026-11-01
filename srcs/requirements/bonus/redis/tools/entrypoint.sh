#!/bin/sh
set -eu

REDIS_PASSWORD=$(cat /run/secrets/redis_password)
umask 077 # perm future files
printf 'requirepass %s\n' "$REDIS_PASSWORD" > /etc/redis/secret.conf
chown redis:redis /etc/redis/secret.conf

exec setpriv --reuid=redis --regid=redis --init-groups redis-server /etc/redis/redis.conf