#!/bin/bash
# Auteur : Maxence Maireaux
# Date : 28/04/2016
# Version : 1.2

#############
# Variables #
#############

. /etc/datacube/datacube.cfg

####################################
### Ajout des scripts de backups ###
####################################
sh /opt/datacube/backup/mysql.sh

##############################
### /!\ Ne pas toucher /!\ ###
##############################

# Réalisation d'un seul fichiers
cd ${dir_backup}/..
${tar_bin} czf ${dir_backup}/../backup_$SERVEURUID-${date}.tar.gz ${dir_backup} >> /dev/null

# On RM le répertoire
rm -rf ${dir_backup} >> /dev/null

# On envoie le backup
cd ${dir_backup}/..
lftp ftp://$FTP_USER:$FTP_PASSWD@$FTP_HOST -e "mirror -R . ${date}/; quit"

GET_TOKEN=$(curl -sL -X POST -F "_username="$USERNAME"" -F "_password="$PASSWORD"" "$API/api/login_check" | jq '.token' |  sed -e 's/^"//' -e 's/"$//')
GET_SIZE=$(du -m ${dir_backup}/../backup_$SERVEURUID-${date}.tar.gz | awk '{print $1}')

# On notifie Datacube
cd ${dir_backup}/..
curl --request POST --url $API/api/backup/$SERVEURUID --header "authorization: Bearer $GET_TOKEN" --form size="$GET_SIZE" --form fileName="backup_$SERVEURUID-${date}.tar.gz"


# On supprime les backups
rm -rf ${dir_backup} >> /dev/null
