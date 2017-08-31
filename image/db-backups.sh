#!/bin/bash

# used mysqldump parameter
# --routines              -> backup stored procedures, default: false
# --events                -> backup events (Events are named database objects containing SQL statements that are to be executed at a later stage, like cron jobs), default: false
# --triggers              -> backup triggers, Mysqldump automatically adds --triggers, but just to be on the safe side in case future versions will remove it, append it as well. default: true
# --single-transaction    -> This option sends a START TRANSACTION SQL statement to the server before dumping data. It is useful only with transactional tables such as InnoDB.

echo $(date) "Starting periodic backups ..."
BACKUP_DIR=/backup

# Select databases
databases=`mysql --defaults-file=${CONFIG_PATH} --ssl -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in ${databases}; do
	timestamp=`date +%Y%m%d%H%M`

    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != _* ]] ; then
    	echo $(date) "Starting mysqldump database: "${db} ", File: "${BACKUP_DIR}/${timestamp}-${db}.sql
        # mysqldump
        mysqldump --defaults-file=${CONFIG_PATH} --ssl --routines --events --triggers --single-transaction --databases ${db} > ${BACKUP_DIR}/${timestamp}-${db}.sql
        
        # zip Dump file
		gzip ${BACKUP_DIR}/${timestamp}-${db}.sql
		
		# encrypt zipped dump file
        openssl smime -encrypt -binary -text -aes256 -in ${BACKUP_DIR}/${timestamp}-${db}.sql.gz -out ${BACKUP_DIR}/${timestamp}-${db}.sql.gz.enc -outform DER /conf/${DB_CRYPT_PUBLIC_KEY_FILENAME} 
		  
        rm -f ${BACKUP_DIR}/${timestamp}-${db}.sql.gz
        chmod 600 ${BACKUP_DIR}/${timestamp}-${db}.sql.gz.enc
    fi
done

exit 0
