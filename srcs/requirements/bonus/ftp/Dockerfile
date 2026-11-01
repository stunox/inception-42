FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends vsftpd && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/run/vsftpd/empty /var/www/html \
 && echo /usr/sbin/nologin >> /etc/shells
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/entrypoint.sh /usr/local/bin/ftp-entrypoint
RUN chmod 755 /usr/local/bin/ftp-entrypoint

EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/ftp-entrypoint"]