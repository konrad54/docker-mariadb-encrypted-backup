#!/bin/sh

echo "entry.sh start..."
echo "$CRON_TIME" " root /scripts/db-backups.sh"

# crontab
# Variable DB_CRYPT_PUBLIC_KEY_FILENAME
echo "DB_CRYPT_PUBLIC_KEY_FILENAME=${DB_CRYPT_PUBLIC_KEY_FILENAME}" > /etc/crontab
echo "CONFIG_PATH=/backup-mysql.cnf" >> /etc/crontab

# Variable CONFIG_PATH for connect to mariadb
CONFIG_PATH=/backup-mysql.cnf
cat > ${CONFIG_PATH} <<EOF
[client]
    user=${MYSQL_USER}
    password=${MYSQL_PASSWORD}
    host=${MYSQL_HOST}
EOF

chmod 400 ${CONFIG_PATH}

# Entry cron job
# It is important that a comment or a blank line is at the end of the table. Similar to the fstab, the crontab must end with a blank line! 
echo "$CRON_TIME" " root /scripts/db-backups.sh >> /var/log/backup.log 2>&1" >> /etc/crontab
echo "" >> /etc/crontab

#Start cron and log
touch /var/log/backup.log
cron && tail -f /var/log/backup.log

exit 0
