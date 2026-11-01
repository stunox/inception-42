FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && rm -rf /var/lib/apt/lists/*

COPY conf/server.cnf /etc/mysql/mariadb.conf.d/60-inception.cnf
COPY tools/entrypoint.sh /usr/local/bin/mariadb-entrypoint
RUN chmod 755 /usr/local/bin/mariadb-entrypoint && mkdir -p /run/mysqld /var/lib/mysql && chown -R mysql:mysql /run/mysqld /var/lib/mysql

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint"]
