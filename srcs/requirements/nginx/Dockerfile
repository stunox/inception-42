FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/sites-available/default
COPY tools/entrypoint.sh /usr/local/bin/nginx-entrypoint
RUN chmod 755 /usr/local/bin/nginx-entrypoint

RUN sed -i '/ssl_protocols/d' /etc/nginx/nginx.conf \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/nginx-entrypoint"]
