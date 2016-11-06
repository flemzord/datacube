#!/bin/bash
# Auteur : Maxence Maireaux
# Version : 1.2

## /!\ Dont't touch !!


#############
# Variables #
#############

. /etc/datacube/datacube.cfg
. /opt/datacube/config/no-touch.cfg

##########
# Script #
##########

# Backup des bases de données
for database_list in `${mysql_bin} -ss -e "SHOW DATABASES" | egrep -vi "^(information_schema|performance_schema)$"`; do
 ${mysqldump_bin} --events --opt -Q -B ${database_list} | ${gzip_bin} -c > ${BACKUP_DIR}/backup_MySQL_${database_list}.sql.gz
done
