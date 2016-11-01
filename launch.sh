#!/bin/bash
# Auteur : Maxence Maireaux
# Date : 28/04/2016
# Version : 1.2

#############
# Variables #
#############

. /etc/datacube/datacube.cfg

# Création des dossiers de backups
${mkdir_bin} -p ${BACKUP_DIR}

####################################
### Ajout des scripts de backups ###
####################################
sh /opt/datacube/backup/mysql.sh
sh /opt/datacube/backup/files.sh

##############################
### /!\ Ne pas toucher /!\ ###
##############################

# Réalisation d'un seul fichiers
cd ${BACKUP_DIR}
${tar_bin} czf ${BACKUP_DIR}/backup_$SERVEURUID-${date}.tar.gz /tmp/ >> /dev/null

# On RM le contenue du répertoire
rm -rf ${BACKUP_DIR}/* >> /dev/null

#On replace le fichier de backup
mv /tmp/backup_$SERVEURUID-${date}.tar.gz ${BACKUP_DIR}/

# On envoie le backup
cd ${BACKUP_DIR}
lftp ftp://$FTP_USER:$FTP_PASSWD@$FTP_HOST -e "mirror -R . ${date}/; quit"

GET_TOKEN=$(curl -sL -X POST -F "_username="$USERNAME"" -F "_password="$PASSWORD"" "$API/api/login_check" | jq '.token' |  sed -e 's/^"//' -e 's/"$//')
GET_SIZE=$(du -m ${BACKUP_DIR}/backup_$SERVEURUID-${date}.tar.gz | awk '{print $1}')

# On notifie Datacube
cd ${BACKUP_DIR}
curl --request POST --url $API/api/backup/$SERVEURUID --header "authorization: Bearer $GET_TOKEN" --form size="$GET_SIZE" --form fileName="backup_$SERVEURUID-${date}.tar.gz"


# On supprime les backups
rm -rf ${BACKUP_DIR} >> /dev/null
