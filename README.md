# konrad54/mariadb-encrypted-backup

Licence AGPLv3

This Docker image runs a configurable cron backup of a another separated mariadb server (not included in this image).

## Prepare private & public key for encrypt and decrypt backup files

``` sh
openssl req -x509 -nodes -newkey rsa:4096 -keyout mysqldump-secure.priv.pem -out mysqldump-secure.pub.pem -subj '/C=a/ST=b/L=c/O=d/OU=e/CN=example.com/emailAddress=test@example.com'
docker container run --rm -v /PATH_TO/mysqldump-secure.pub.pem:/source:ro  -v db_conf:/target alpine:latest cp -TR /source /target/mysqldump-secure.pub.pem
```

## Run backup container
docker container run --name=db-backup -d \
 -e CRON_TIME="10 3,15 * * *" \
 -e MYSQL_HOST="example.com" \
 -e MYSQL_USER="username" \
 -e MYSQL_PASSWORD="password" \
 -e DB_CRYPT_PUBLIC_KEY_FILENAME="mysqldump-secure.pub.pem" \
 -e MARIADB_BACKUP_TTL=15 \
 -v /YOUR_BACKUP_DIRECTORY:/backup:rw \
 -v db_conf:/conf:ro \
 konrad54/mariadb-encrypted-backup:1.0.4


## Restore mysqldump

1. Drop your database scheme

2. Restore mysqldump via container

``` sh
cd /YOUR_BACKUP_DIRECTORY
docker container run --entrypoint /scripts/db-restore.sh --rm --add-host example.com:192.168.55.99 \
 -e MYSQL_HOST="example.com" \
 -e MYSQL_USER="username" \
 -e MYSQL_PASSWORD="password" \
 -e DB_CRYPT_PRIVATE_KEY_FILENAME="mysqldump-secure.priv.pem" \
 -e BACKUP_FILENAME="201708310912-mysql.sql.gz.enc" \
 -v /YOUR_BACKUP_DIRECTORY:/backup \
 -v /PATH_TO/mysqldump-secure.priv.pem:/mysqldump-secure.priv.pem \
 konrad54/mariadb-encrypted-backup:1.0.4
```


## How to build image local

``` sh
mkdir /tmp/mariadb-encrypted-backup
cd /tmp/mariadb-encrypted-backup
vi Dockerfile
vi entry.sh
vi db-backups.sh
vi db-restore.sh

docker build -t konrad54/mariadb-encrypted-backup:1.0.4 . 