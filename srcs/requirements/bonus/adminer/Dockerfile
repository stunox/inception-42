FROM debian:bookworm

ARG ADMINER_VERSION=4.8.1
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl php8.2-cli php8.2-mysql && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/www/adminer \
 && curl -fsSLo /var/www/adminer/index.php "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php" \
 && useradd -r -s /usr/sbin/nologin adminer && chown -R adminer /var/www/adminer
USER adminer
WORKDIR /var/www/adminer
EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]