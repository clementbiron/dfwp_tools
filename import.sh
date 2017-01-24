#!/usr/bin/env bash
#
#
#
# Script d'import de BDD
# Accès SSH nécesaire
#
#
#

# Config vhost
vhost_local='http://localhost/exemple'
vhost_dist='http://preprod.exemple.com'

# Config path
tmp_dist_folder='/home/username/tmp'
project_dist_folder='/home/username/public_html/preprod/exemple'

# Config file name
d=$(date +%Y-%m-%d_%Hh-%Mm-%Ss)
#export_file_name='export-'$d'.sql'
export_file_name='export-'$d'.xml'

# Config SSH
ssh_info='user@server'

echo "On exporte la base distante"
$wp search-replace $vhost_dist $vhost_local --export=$project_dist_folder/$export_file_name --ssh=$ssh_info --path=$project_dist_folder
echo "--------------------------------------"

echo "Copie de du fichier sql sur la machine locale"
scp $ssh_info:$project_dist_folder/$export_file_name $export_file_name
echo "--------------------------------------"

echo "Import de la bdd "
$wp db import $export_file_name
echo "--------------------------------------"

echo "Suppression du fichier d'import en local"
# rm $export_file_name
echo "--------------------------------------"

exit