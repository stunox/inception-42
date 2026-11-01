FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl php8.2-cli php8.2-fpm php8.2-mysql php-redis php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-intl && rm -rf /var/lib/apt/lists/* && curl -fsSLo /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod 755 /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/wordpress-entrypoint
RUN chmod 755 /usr/local/bin/wordpress-entrypoint && mkdir -p /run/php /var/www/html && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint"]
