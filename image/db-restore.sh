#!/bin/bash

BACKUP_FILE_GZ_ENC=$BACKUP_FILENAME
BACKUP_FILE_GZ=${BACKUP_FILE_GZ_ENC%.*}
BACKUP_FILE=${BACKUP_FILE_GZ%.*}
BACKUP_PATH=/backup
CONFIG_PATH=/tmp/.backup-mysql.cnf

cat > ${CONFIG_PATH} <<EOF
[client]
    user=${MYSQL_USER}
    password=${MYSQL_PASSWORD}
    host=${MYSQL_HOST}
EOF

chmod 400 ${CONFIG_PATH}

echo "Decrypting " $BACKUP_PATH/$BACKUP_FILE_GZ_ENC
openssl smime -decrypt -in $BACKUP_PATH/$BACKUP_FILE_GZ_ENC -binary -inform DEM -inkey /$DB_CRYPT_PRIVATE_KEY_FILENAME -out $BACKUP_PATH/$BACKUP_FILE_GZ

echo "Unzipping " ${BACKUP_PATH}/${BACKUP_FILE_GZ}
gzip --keep -d ${BACKUP_PATH}/${BACKUP_FILE_GZ}

echo "Restoring sqldump " $BACKUP_PATH/$BACKUP_FILE
mysql --defaults-file=${CONFIG_PATH} --ssl < ${BACKUP_PATH}/${BACKUP_FILE}   

rm ${CONFIG_PATH}
rm ${BACKUP_PATH}/${BACKUP_FILE}  
rm ${BACKUP_PATH}/${BACKUP_FILE_GZ}

exit 0

