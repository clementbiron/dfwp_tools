#!/bin/bash
#
# Automatize WordPress installation
# bash install.sh
#
# Inspirated from Maxime BJ
# For more information, please visit 
# http://www.wp-spread.com/tuto-wp-cli-comment-installer-et-configurer-wordpress-en-moins-dune-minute-et-en-seulement-un-clic/

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
#  VARS
#  ==============================

# Root Path
# Si pas de valeur renseignée, message d'erreur et exit
read -p "Root path (exemple : /var/www/public/ ) ? " rootpath
if [ -z $rootpath ]
	then
		error 'Renseigner un root path'
		exit
fi

# On récupère l'url
# Si pas de valeur renseignée, message d'erreur et exit
read -p "Url du projet ? " url
if [ -z $url ]
	then
		error 'Renseigner une url'
		exit
fi

# On récupère le nom du dossier
# Si pas de valeur renseignée, message d'erreur et exit
read -p "Nom du dossier ? " foldername
if [ -z $foldername ]
	then
		error 'Renseigner un nom de dossier'
		exit
fi

# On récupère le titre du site
# Si pas de valeur renseignée, message d'erreur et exit
read -p "Titre du projet ? " title
if [ -z "$title" ]
	then
		error 'Renseigner un titre pour le site'
		exit
fi

# Chemin vers le fichier .txt qui liste les plugins à installer
read -p "Chemin vers le fichier .txt qui liste les plugins à installer ? " pluginfilepath

# On récupère la clé acf si disponible
read -p "Clé ACF pro ? " acfkey;


# Langue d'installation de WP ?
wplang="fr_FR"

# TODO : quand on passe en_EN ça marche pas
# read -p "Code de la langue de WP (fr_FR par défaut) ? " wplang;
# echo $wplang


# Paths
pathtoinstall="${rootpath}${foldername}"

success "Récap"
echo "--------------------------------------"
echo -e "Url : $url"
echo -e "Foldername : $foldername"
echo -e "Titre du projet : $title"
echo -e  "Root path : $rootpath"
echo -e "Path du propjet : $pathtoinstall"
if [ -n "$pluginfilepath" ]
	then
		echo -e "Fichier qui liste les plugins à installer : $pluginfilepath"
fi
if [ -n "$acfkey" ]
	then
		echo -e "Clé ACF pro : $acfkey"
fi
echo -e "Liste des plugins à installer : $pluginfilepath"
echo "--------------------------------------"

# Admin login
adminlogin="nimda"
adminpass="admin"
adminemail="clement.biron@gmail.com"

# DB
dbname=localhost
dbuser=root
dbpass=""
dbprefix="irwopzd_$foldername"


#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
success "L'installation va pouvoir commencer"
echo "--------------------------------------"

# CHECK :  Directory doesn't exist
cd $rootpath

# Check if provided folder name already exists
if [ -d $pathtoinstall ]; then
  error "Le dossier $pathtoinstall existe déjà. Par sécurité, je ne vais pas plus loin pour ne rien écraser."
  exit 1
fi

# Create directory
bot "-> Je crée le dossier : $foldername"
mkdir $foldername
cd $foldername

bot "-> Je crée le fichier de configuration wp-cli.yml"
echo "
# Configuration de wpcli
# Voir http://wp-cli.org/config/

# Les modules apaches à charger
apache_modules:
	- mod_rewrite
" >> wp-cli.yml

# Download WP
bot "-> Je télécharge la dernière version de WordPress $wplang..."
wp core download --locale=$wplang --force

# Create base configuration
bot "-> Je lance la configuration de WP"
wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --dbprefix=$dbprefix --extra-php <<PHP
// Désactiver l'éditeur de thème et de plugins en administration
define('DISALLOW_FILE_EDIT', true);

// Changer le nombre de révisions de contenus
define('WP_POST_REVISIONS', 3);

// Supprimer automatiquement la corbeille tous les 7 jours
define('EMPTY_TRASH_DAYS', 7);

//Mode debug
define('WP_DEBUG', true);
PHP

# Create database
bot "-> Je crée la base de données"
wp db create

# Launch install
bot "-> J'installe WordPress..."
wp core install --url=$url --title="$title" --admin_user=$adminlogin --admin_email=$adminemail --admin_password=$adminpass

# Si on a bien un fichier qui listes les plugins à installer
if [ -n "$pluginfilepath" ]
	then
	    # Plugins install
        bot "-> J'installe les plugins à partir de la liste"
        while read line || [ -n "$line" ]
        do
            bot "-> Plugin $line"
            wp plugin install $line --activate
        done < $pluginfilepath
fi

# Si on a bien une clé acf pro
if [ -n "$acfkey" ]
	then
		bot "-> J'installe la version pro de ACF"
		cd $pathtoinstall
		cd wp-content/plugins/
		curl -L -v 'http://connect.advancedcustomfields.com/index.php?p=pro&a=download&k='$acfkey > advanced-custom-fields-pro.zip
		wp plugin install advanced-custom-fields-pro.zip --activate
fi

# Download from private git repository
bot "-> Je télécharge le thème DFWP"
cd $pathtoinstall/wp-content/themes/
git clone https://github.com/posykrat/dfwp.git

bot "-> Je télécharge le thème DFWP_CHILD"
git clone https://github.com/posykrat/dfwp_child.git

bot "-> Je copie le dossier dfwp_child vers $foldername"
cp -rf dfwp_child $foldername

bot "-> Je configure le thème $foldername"
cd $pathtoinstall/wp-content/themes/$foldername/build/
npm install
bower install
rm -r -f  .git

# Supprimer le dossier git
bot "-> Je supprime le dossier .git du thème $foldername"
cd $pathtoinstall/wp-content/themes/$foldername/
rm -r -f  .git

# Modifier le fichier style.css
bot "-> Je modifie le fichier style.css du thème $foldername"
cd $pathtoinstall/wp-content/themes/
echo "/* 
	Theme Name: $foldername
	Description: Child of DFWP theme framework
	Author: Clément Biron
	Template: dfwp
	Version: 1.0 
*/" > $foldername/style.css

# Activate theme
bot "-> J'active le thème $foldername:"
wp theme activate $foldername

# Misc cleanup
bot "-> Je supprime les posts, comments et terms"
wp site empty --yes

bot "-> Je supprime Hello dolly et les themes de bases"
wp plugin delete hello
wp theme delete twentyfifteen
wp theme delete twentyseventeen
wp theme delete twentysixteen
wp option update blogdescription ''

# Create standard pages
bot "-> Je crée les pages standards accueil et mentions légales"
wp post create --post_type=page --post_title='Accueil' --post_status=publish
wp post create --post_type=page --post_title='Mentions Légales' --post_status=publish

# La page d'accueil est une page
# Et c'est la page qui se nomme accueil
bot "-> Configuration de la page accueil"
wp option update show_on_front 'page'
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=Accueil --field=ID --format=ids)

# Permalinks to /%postname%/
bot "-> J'active la structure des permaliens /%postname%/ et génère le fichier .htaccess"
wp rewrite structure "/%postname%/" --hard
wp rewrite flush --hard

#Modifier le fichier htaccess
bot "-> J'ajoute des règles Apache dans le fichier htaccess"
cd $pathtoinstall
echo "
#Interdire le listage des repertoires
Options All -Indexes

#Interdire l'accès au fichier wp-config.php
<Files wp-config.php>
 	order allow,deny
	deny from all
</Files>

#Intedire l'accès au fichier htaccess lui même
<Files .htaccess>
	order allow,deny 
	deny from all 
</Files>
" >> .htaccess

# Créer la page du styleguide
bot "-> Je crée la page pour le styleguide et l'associe au template qui va bien."
wp post create --post_type=page --post_title='Styleguide' --post_status=publish --page_template='page-styleguide.php'


# Si on veut versionner le projet sur Bibucket
read -p "Versionner le projet sur Bitbucket (y/n) ? " yn
case "$yn" in
    y ) 
		# On se positione dans le dossier du thème
		cd $pathtoinstall
		cd wp-content/themes/
		cd $foldername

		# On supprime le dossier git présent
		rm -f -r .git
	
		# On récupère les infos nécessaire
		read -p "Login ? " login
		read -p "Password ? " pass
		read -p "Nom du dépôt ? " depot
		
		#Créer le dépôt sur Bitbucket
		curl --user $login:$pass https://api.bitbucket.org/1.0/repositories/ --data name=$depot --data is_private='true'
	    
	    # Init git et lien avec le dépôt
	    git init 
	    git remote add origin git@bitbucket.org:$login/$depot.git 
	    
	    # Ajouter les fichiers untracked, commit et push toussa
	    git add -A 
	    git commit -m 'first commit'
	    git push -u origin master

	    success "-> OK ! adresse du dépôt est : https://bitbucket.org/$login/$depot";;
    n ) 
		echo "Tans pis !";;
esac


# Finish !
success "L'installation est terminée !"
echo "--------------------------------------"
echo -e "Url			: $url"
echo -e "Path			: $pathtoinstall"
echo -e "Admin login	: $adminlogin"
echo -e "Admin pass		: $adminpass"
echo -e "Admin email	: $adminemail"
echo -e "DB name 		: $dbname"
echo -e "DB user 		: $dbuser"
echo -e "DB pass 		: $dbpass"
echo -e "DB prefix 		: irwopzd_$foldername"
echo -e "WP_DEBUG 		: TRUE"
echo "--------------------------------------"



# Menu stuff
# echo -e "Je crée le menu principal, assigne les pages, et je lie l'emplacement du thème : "
# wp menu create "Menu Principal"
# wp menu item add-post menu-principal 3
# wp menu item add-post menu-principal 4
# wp menu item add-post menu-principal 5
# wp menu location assign menu-principal main-menu

# Git project
# REQUIRED : download Git at http://git-scm.com/downloads
# echo -e "Je Git le projet :"
# cd ../..
# git init    # git project
# git add -A  # Add all untracked files
# git commit -m "Initial commit"   # Commit changes
