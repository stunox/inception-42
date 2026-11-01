#!/bin/sh
set -eu

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -o -u 33 -g 33 -M -d /var/www/html -s /usr/sbin/nologin "$FTP_USER"
fi
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
sed -i "s/^pasv_address=.*/pasv_address=${FTP_PASV_ADDRESS}/" /etc/vsftpd.conf

exec vsftpd /etc/vsftpd.conf