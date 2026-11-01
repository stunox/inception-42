#!/bin/sh
set -eu

DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
USER_PASSWORD=$(cat /run/secrets/wp_user_password)

cd /var/www/html

if [ ! -f wp-load.php ]; then
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    wp config create --allow-root --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost=mariadb --dbcharset=utf8mb4 --extra-php <<'PHP'
define('FORCE_SSL_ADMIN', true);
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
    $_SERVER['HTTPS'] = 'on';
}
PHP
fi

if ! wp core is-installed --allow-root; then
    wp core install --allow-root --url="https://${DOMAIN_NAME}" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --skip-email
fi

if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
    wp user create "$WP_USER" "$WP_USER_EMAIL" --allow-root --role=author --user_pass="$USER_PASSWORD"
fi

chown -R www-data:www-data /var/www/html
exec php-fpm8.2 -F
