#!/bin/bash
# Auteur : Maxence Maireaux
# Version : 1.0

#############
# Variables #
#############

. /etc/datacube/datacube.cfg

##########
# Script #
##########
dir_sites="/home/sites/"

# Backup des fichiers du sites
cd ${dir_sites}
for site_list in `ls`; do
 tar czf ${dir_backup}/backup_Files_${site_list}.tar.gz ${site_list};
done
