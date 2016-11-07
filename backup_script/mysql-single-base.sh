#!/bin/bash
# Auteur : Maxence Maireaux
# Version : 1.2

## /!\ Dont't touch !!


#############
# Variables #
#############

. /etc/datacube/datacube.cfg
. /opt/datacube/config/no-touch.cfg

HOST="__MonHOST__"
USER="__MonUser__"
PASSWD="__PASSWD__"
DATABASE="__BDD__"

##########
# Script #
##########

${mysqldump_bin} -h $HOST -u $USER -p$PASSWD --events --opt -Q -B $DATABASE | ${gzip_bin} -c > ${BACKUP_DIR}/backup_MySQL_$DATABASE.sql.gz

