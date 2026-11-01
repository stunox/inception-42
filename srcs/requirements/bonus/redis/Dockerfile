FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends redis-server && rm -rf /var/lib/apt/lists/*
COPY conf/redis.conf /etc/redis/redis.conf
COPY tools/entrypoint.sh /usr/local/bin/redis-entrypoint
RUN chmod 755 /usr/local/bin/redis-entrypoint && mkdir -p /var/lib/redis && chown redis:redis /var/lib/redis

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/redis-entrypoint"]