#!/bin/bash
#
# Script d'expoort de BDD distante
# Accès SSH nécesaire

# 
# Config
#  
vhost_local='http://localhost/project'
projet_local_folder='h:/www/project'
prefix_local=''

vhost_dist='http://preprod.project.com'
project_dist_folder='~/www/preprod/project'
prefix_dist=''

d=$(date +%Y-%m-%d_%Hh-%Mm-%Ss)
export_dist_folder='tmp'
export_file_name='export-local-'$d'.sql'

ssh_info='user@domain.com'
script_dir='h:/www/_lab/import-export/project'

# 
# Process
#  
cd $projet_local_folder
pwd

echo "Export de la bdd locale"
php C:/wp-cli/wp-cli.phar search-replace $vhost_local $vhost_dist --export=$export_file_name
echo "--------------------------------------"

echo "On change les prefixes"
sed -i "s/${prefix_local}/${prefix_dist}/g" $export_file_name
echo "--------------------------------------"

echo "On copie le fichier sql dans le dossier du script"
cp $export_file_name $script_dir
echo "--------------------------------------"

echo "Suppression du fichier .sql dans le dossier du projet"
rm -f $export_file_name
echo "--------------------------------------"

echo "Copie du fichier sql sur le serveur distant"
cd $script_dir
scp $export_file_name $ssh_info:$project_dist_folder
echo "--------------------------------------"

ssh $ssh_info "
	
	echo "On se positione dans le dossier du projet sur le serveur distant"
	cd $project_dist_folder
	echo "--------------------------------------"

	echo "On importe la base locale sur le serveur distant"
	wp db import $export_file_name
	echo "--------------------------------------"

	echo "Suppression du fichier .sql sur le serveur distant"
	rm -f $export_file_name
	echo "--------------------------------------"

	exit
"

exit