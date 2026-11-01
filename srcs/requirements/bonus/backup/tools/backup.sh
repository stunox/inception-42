#!/bin/sh
set -eu
umask 077

STAMP=$(date +%Y%m%d-%H%M%S)
KEEP="${BACKUP_KEEP:-7}"
DB_PASSWORD=$(cat /run/secrets/db_password)
OUT="/backups/db-${STAMP}.sql"

if ! MYSQL_PWD="$DB_PASSWORD" mariadb-dump -h mariadb -u "$DB_USER" --single-transaction --no-tablespaces "$DB_NAME" > "$OUT"; then
    rm -f "$OUT"
    echo "backup ${STAMP}: database dump failed" >&2
    exit 1
fi
gzip "$OUT"
tar -czf "/backups/wordpress-${STAMP}.tar.gz" -C /var/www/html .

for prefix in db wordpress; do
    ls -1t /backups/${prefix}-* 2>/dev/null | tail -n +$((KEEP + 1)) | xargs -r rm -f
done
echo "backup ${STAMP}: done"