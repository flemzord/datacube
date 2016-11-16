#!/bin/bash
# Auteur : Maxence Maireaux
# Date : 28/04/2016
# Version : 1.2

#############
# Variables #
#############

. /etc/datacube/datacube.cfg
. /opt/datacube/config/no-touch.cfg
. /opt/datacube/config/date.cfg

# Création des dossiers de backups
${mkdir_bin} -p ${BACKUP_DIR}

####################################
### Ajout des scripts de backups ###
####################################
. /opt/datacube/load_script.sh

##############################
### /!\ Ne pas toucher /!\ ###
##############################

# Réalisation d'un seul fichiers
cd ${BACKUP_DIR}
${tar_bin} czf /tmp/backup_$SERVEURUID-${date_files}.tar.gz ${BACKUP_DIR}/ >> /dev/null

# On RM le contenue du répertoire
rm -rf ${BACKUP_DIR}/* >> /dev/null

#On replace le fichier de backup
mv /tmp/backup_$SERVEURUID-${date_files}.tar.gz ${BACKUP_DIR}/

#############################################
### Ajout des scripts de post-traintement ###
#############################################
# /!\ Use folder custom_launch

# Solution pour chiffrer les sauvegardes (il faut modifier le /etc/datacube/datacube.cfg)
# /!\ Il ne faut surtout pas perdre la clée de cryptage ! Sinon vous ne pourrez plus récupérer vos fichiers ! /!\
cd ${BACKUP_DIR}/
echo "On chiffre la sauvegarde"
# On chiffre le fichier
${openssl_bin} enc -in backup_$SERVEURUID-${date_files}.tar.gz -out backup_crypt_$SERVEURUID-${date_files}.tar.gz -e -aes256 -k ${KEY_CRYPT}
# On supprime l'ancien fichier
rm -rf backup_$SERVEURUID-${date_files}.tar.gz
# On déplace le fichier
mv backup_crypt_$SERVEURUID-${date_files}.tar.gz backup_$SERVEURUID-${date_files}.tar.gz

##############################
### /!\ Ne pas toucher /!\ ###
##############################

# On envoie le backup
cd ${BACKUP_DIR}
lftp ftp://$FTP_USER:$FTP_PASSWD@$FTP_HOST -e "mirror -R ${BACKUP_DIR} /; quit"

GET_TOKEN=$(curl -sL -X POST -F "_username="$USERNAME"" -F "_password="$PASSWORD"" "$API/api/login_check" | jq '.token' |  sed -e 's/^"//' -e 's/"$//')
GET_SIZE=$(du -m ${BACKUP_DIR}/backup_$SERVEURUID-${date_files}.tar.gz | awk '{print $1}')

# On notifie Datacube
cd ${BACKUP_DIR}
curl --request POST --url $API/api/backup/$SERVEURUID --header "authorization: Bearer $GET_TOKEN" --form size="$GET_SIZE" --form fileName="backup_$SERVEURUID-${date_files}.tar.gz"


# On supprime les backups
rm -rf ${BACKUP_DIR} >> /dev/null
rm -rf /tmp/datacube.date
