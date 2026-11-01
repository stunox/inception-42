#!/bin/sh
set -eu

DB_PASSWORD=$(cat /run/secrets/db_password)
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal --skip-test-db
fi
if [ ! -f /var/lib/mysql/.initialized ]; then
    mariadbd --user=mysql --bootstrap --skip-networking <<SQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL
    touch /var/lib/mysql/.initialized
fi

mariadbd --user=mysql --skip-networking &
TEMP_PID=$!
for attempt in $(seq 1 30); do
    if mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

mariadb --socket=/run/mysqld/mysqld.sock -uroot --password="$ROOT_PASSWORD" <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
DROP USER IF EXISTS 'root'@'127.0.0.1', 'root'@'::1';
EXECUTE IMMEDIATE CONCAT('DROP USER IF EXISTS root@''', @@hostname, '''');
FLUSH PRIVILEGES;
SQL

kill "$TEMP_PID"
wait "$TEMP_PID" || true

touch /var/lib/mysql/.initialized

exec mariadbd --user=mysql --console
