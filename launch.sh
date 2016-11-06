#!/bin/bash
# /!\ Use folder custom_script

#Sauvegarde MySQL (auto-login)
echo "On lance la sauvegarde MySQL"
sh /opt/datacube/backup_script/mysql.sh

#Sauvegarde des fichiers
echo "On lance la sauvegrade des fichiers"
sh /opt/datacube/backup_script/files.sh