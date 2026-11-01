#!/bin/sh
set -eu

if [ ! -f srcs/.env ]; then
    cp srcs/.env.example srcs/.env
fi

mkdir -p secrets
for name in db_password db_root_password wp_admin_password wp_user_password; do
    if [ ! -s "secrets/${name}.txt" ]; then
        openssl rand -hex 24 > "secrets/${name}.txt"
    fi
done

login=$(sed -n 's/^LOGIN=//p' srcs/.env)
mkdir -p "/home/${login}/data/database" "/home/${login}/data/wordpress"
