FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends cron mariadb-client && rm -rf /var/lib/apt/lists/*
COPY tools/backup.sh /usr/local/bin/backup
COPY tools/entrypoint.sh /usr/local/bin/backup-entrypoint
RUN chmod 755 /usr/local/bin/backup /usr/local/bin/backup-entrypoint && mkdir -p /backups

ENTRYPOINT ["/usr/local/bin/backup-entrypoint"]