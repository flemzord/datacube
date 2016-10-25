#!/bin/bash
# Auteur : Maxence Maireaux
# Date : 28/04/2015
# Version : 1.2

#############
# Variables #
#############

. /etc/datacube/datacube.cfg

##########
# Script #
##########
# Création des dossiers de backups
${mkdir_bin} -p ${dir_backup}

# Backup des bases de données
for database_list in `${mysql_bin} -ss -e "SHOW DATABASES" | egrep -vi "^(information_schema|performance_schema)$"`; do
 ${mysqldump_bin} --events --opt -Q -B ${database_list} | ${gzip_bin} -c > ${dir_backup}/backup_MySQL_${database_list}.sql.gz
done
