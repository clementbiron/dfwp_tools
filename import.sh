#!/bin/bash
#
# Script d'import de BDD
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
export_file_name='export-'$d'.sql'

ssh_info='user@domain.com'


# 
# Process
#  
ssh $ssh_info "
	
	echo "On se positione dans le dossier du projet"
	cd $project_dist_folder
	pwd
	echo "--------------------------------------"

	echo "On exporte la base distante"
	wp search-replace $vhost_dist $vhost_local --export=$export_file_name
	echo "--------------------------------------"

	exit
"

echo "Copie de du fichier sql sur la machine locale"
scp $ssh_info:$project_dist_folder/$export_file_name $export_file_name
echo "--------------------------------------"

ssh $ssh_info "
	echo "On supprime le fichier sur la machine distante"
	cd $project_dist_folder
	rm -f $export_file_name
"
echo "--------------------------------------"

echo "On change les prefixes"
sed -i "s/${prefix_dist}/${prefix_local}/g" $export_file_name
echo "--------------------------------------"

echo "On copie le fichier sql dans le dossier du projet local"
cp $export_file_name $projet_local_folder/$export_file_name
echo "--------------------------------------"

echo "On importe la base en local"
cd $projet_local_folder
wp db import $export_file_name
echo "--------------------------------------"

echo "Suppression du fichier .sql dans le dossier du projet"
rm -f $export_file_name
echo "--------------------------------------"

exit