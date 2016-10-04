# dfwp_tools
Suite de script pour WordPress
Testé dans un environnement Windows, à adapter à vos besoins.

---

### install.sh
WordPress auto install with WP-Cli

Warning: this script is no longer valid, please adapted it to your needs

## Features
- Install WordPress (fr only for now)
- Clear default WordPress content and plugin
- Create standards pages 'Accueil' and 'Mentions légales'
- Setup homepage with 'Accueil' page
- Setup permalink with /%postname%/ structure and generate .htaccess file
- Add Apache rules in .htaccess file
- Add WordPress rules in wp-config file
- Download dfwp theme framework and dfwp_child theme starter
- Active custom theme with a copy of dfwp_child theme
- Install and active listed plugins in txt file
- Install and active ACF Pro with your keygen
- Allow to push projet on BitBucket

## Use :
bash install.sh

---

### export.sh

Warning: it's a draft copy, please don't use before checking the code and adpat it 

## Features
- Export local database and rename url
- Copy local backup of database to remote server via scp
- Import databse in the remote server

## Use :
bash export.sh

---

### import.sh

Warning: not functionnal for now
