#!/bin/bash
#
# Automatize WordPress installation
# bash install.sh url foldername "title"
# $1 = url
# $2 = folder name
# $3 = site title

#  ==============================
#  VARS
#  ==============================

# local url 
url=$1

# folder name
foldername=$2

# path to install your WPs
rootpath="/var/www/public/"
pathtoinstall="${rootpath}${foldername}"

# wp title
title=$3

# admin login
adminlogin="admin"
adminpass="admin"
adminemail="clement.biron@gmail.com"

#DB
dbname=localhost
dbuser=root
dbpass=root
dbprefix="pwrxt_$foldername"


#  ==============================
#  ECHO COLORS, FUNCTIONS AND VARS
#  ==============================
bggreen='\033[42m'
bgred='\033[41m'
bold='\033[1m'
black='\033[30m'
gray='\033[37m'
normal='\033[0m'

# Jump a line
function line {
	echo " "
}

# Basic echo
function bot {
	line
	echo -e "$1 ${normal}"
}

# Error echo
function error {
	line
	echo -e "${bgred}${bold}${gray} $1 ${normal}"
}

# Success echo
function success {
	line
	echo -e "${bggreen}${bold}${gray} $1 ${normal}"
}


#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
success "L'installation va pouvoir commencer"
echo "--------------------------------------"

# CHECK :  Directory doesn't exist
cd $rootpath

# check if provided folder name already exists
if [ -d $pathtoinstall ]; then
  error "Le dossier $pathtoinstall existe déjà. Par sécurité, je ne vais pas plus loin pour ne rien écraser."
  exit 1
fi

# create directory
bot "Je crée le dossier : $foldername"
mkdir $foldername
cd $foldername

# Download WP
bot "Je télécharge la dernière version de WordPress en français..."
wp core download --locale=fr_FR --force

# check version
bot "J'ai récupéré cette version :"
wp core version

# create base configuration
bot "Je lance la configuration :"
wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --dbprefix=$dbprefix --extra-php <<PHP
// Désactiver l'éditeur de thème et de plugins en administration
define('DISALLOW_FILE_EDIT', true);

// Changer le nombre de révisions de contenus
define('WP_POST_REVISIONS', 3);

// Supprimer automatiquement la corbeille tous les 7 jours
define('EMPTY_TRASH_DAYS', 7);

//Mode debug
define( 'WP_DEBUG', true );
PHP

# Create database
bot "Je crée la base de données :"
wp db create

# Launch install
bot "J'installe WordPress..."
wp core install --url=$url --title="$title" --admin_user=$adminlogin --admin_email=$adminemail --admin_password=$adminpass

# Download from private git repository
bot "Je télécharge le thème DFWP :"
cd wp-content/themes/
git clone https://github.com/posykrat/dfwp.git

bot "Je télécharge le thème DFWP_CHILD : "
cd wp-content/themes/
git clone https://github.com/posykrat/dfwp_child.git

# Create standard pages
# echo -e "Je crée les pages habituelles (Accueil, blog, contact...)"
# wp post create --post_type=page --post_title='Accueil' --post_status=publish
# wp post create --post_type=page --post_title='Blog' --post_status=publish
# wp post create --post_type=page --post_title='Contact' --post_status=publish
# wp post create --post_type=page --post_title='Mentions Légales' --post_status=publish

# Create fake posts
# echo -e "Je crée quelques faux articles"
# curl http://loripsum.net/api/5 | wp post generate --post_content --count=5

# Change Homepage
# echo -e "Je change la page d'accueil et la page des articles"
# wp option update show_on_front page
# wp option update page_on_front 3
# wp option update page_for_posts 4

# Menu stuff
# echo -e "Je crée le menu principal, assigne les pages, et je lie l'emplacement du thème : "
# wp menu create "Menu Principal"
# wp menu item add-post menu-principal 3
# wp menu item add-post menu-principal 4
# wp menu item add-post menu-principal 5
# wp menu location assign menu-principal main-menu

# Misc cleanup
bot "Je supprime Hello Dolly, les thèmes de base et les articles exemples"
wp post delete 1 --force # Article exemple - no trash. Comment is also deleted
wp post delete 2 --force # page exemple
wp plugin delete hello
wp theme delete twentyfourteen
wp theme delete twentythirteen	
wp option update blogdescription ''

# Permalinks to /%postname%/
bot "J'active la structure des permaliens"
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

# Rename child theme
bot "Je renomme le theme DFWP_CHILD en $foldername"
mv dfwp_child $foldername

# Modify style.css
bot "Je modifie le fichier style.css"
echo "/* 
	Theme Name: $foldername
	Description: Child of DFWP theme framework
	Author: Clément Biron
	Template: dfwp
	Version: 1.0 
*/" > $foldername/style.css

# Activate theme
bot "J'active le thème $foldername:"
wp theme activate $foldername

# Git project
# REQUIRED : download Git at http://git-scm.com/downloads
# echo -e "Je Git le projet :"
# cd ../..
# git init    # git project
# git add -A  # Add all untracked files
# git commit -m "Initial commit"   # Commit changes

# Finish echo
success "L'installation est terminée !"
echo "--------------------------------------"
echo -e "Url			: $url"
echo -e "Path			: $pathtoinstall"
echo -e "Admin login	: $adminlogin"
echo -e "Admin pass		: $adminpass"
echo -e "Admin email	: $adminemail"
echo -e "DB name 		: localhost"
echo -e "DB user 		: root"
echo -e "DB pass 		: root"
echo -e "DB prefix 		: pwrxt_$foldername"
echo -e "WP_DEBUG 		: TRUE"
echo "--------------------------------------"