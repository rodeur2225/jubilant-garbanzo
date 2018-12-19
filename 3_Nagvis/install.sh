#!/bin/bash
echo "verification de l'installation de mlocate"
yum install -y -q mlocate
echo "verfification de l'instalation de nagvis"
sleep 2
$pwd= `locate --regex ^/usr/share/nagvis$`
if [ ! $pwd == "/usr/share/nagvis" ];then
  echo "nagvis n'est pas installé fin de l'installation (voire les ateleir de kermith pour l'installation)"
  exit 2
fi
echo "nagvis est present exportation des icones vers nagvis"
sleep 2
mv ./*_*/*_* /usr/share/nagvis/share/userfiles/images/iconsets
echo "vos icones sont installé les voici"
sleep 2
ls /usr/share/nagvis/share/userfiles/images/iconsets
echo "appuyer sur <entrer> pour quitter l'installation"
read touche
clear 
exit 0
