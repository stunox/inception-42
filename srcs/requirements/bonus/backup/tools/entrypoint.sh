#!/bin/sh
set -eu

SCHEDULE="${BACKUP_SCHEDULE:-0 3 * * *}"
{
    printf 'DB_USER=%s\nDB_NAME=%s\nBACKUP_KEEP=%s\n' "$DB_USER" "$DB_NAME" "${BACKUP_KEEP:-7}"
    printf '%s root /usr/local/bin/backup >> /proc/1/fd/1 2>&1\n' "$SCHEDULE"
} > /etc/cron.d/backup
chmod 644 /etc/cron.d/backup

exec cron -f