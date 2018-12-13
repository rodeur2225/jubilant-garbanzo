#!/bin/bash
yum install -y -q mlocate
echo "verfification de l'intalation de nagvis"
$pwd=`locate --regex /usr/share/nagvis$
if [ ! $pwd == "/usr/share/nagvis" ];then
  echo "nagvis n'est pas installé fin de l'installation"
  exit 2
fi
echo "nagvis est present exportation des icon vers nagvis"
mv ./*_*/*_* /usr/share/nagvis/share/userfiles/images/iconsets
echo "vos icones sont installé les voici"
ls /usr/share/nagvis/share/userfiles/images/iconsets
echo "appuyer sur <entrer> pour quitter l'installation"
read touche
clear 
exit 0
