#!/bin/bash
# Auteur : Maxence Maireaux
# Version : 1.0

#############
# Variables #
#############

. /etc/datacube/datacube.cfg
. /opt/datacube/no-touch.cfg

##########
# Script #
##########
cd ${BACKUP_DIR}/

echo "On chiffre la sauvegarde"

# On chiffre le fichier
${openssl_bin} enc -in backup_$SERVEURUID-${date_files}.tar.gz -out backup_crypt_$SERVEURUID-${date_files}.tar.gz -e -aes256 -k ${KEY_CRYPT}

# On supprime l'ancien fichier
rm -rf backup_$SERVEURUID-${date_files}.tar.gz

# On déplace le fichier
mv backup_crypt_$SERVEURUID-${date_files}.tar.gz backup_$SERVEURUID-${date_files}.tar.gz