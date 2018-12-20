# installation d'iconeset pour nagvis

### nécessite : 
+ [Centreon](https://www.centreon.com/en/) 
+ [Nagvis](http://www.sugarbug.fr/atelier/techniques/ihmweb/cartographie_supervision/centreon-web28x_nagvis-19x/)
+ [Git](https://gist.github.com/derhuerst/1b15ff4652a867391f03)

## l'install

dans le dossier 3_Nagvis il y a un fichier install.sh lancez le et vous n'aurez plus rien a faire le detail de l'installation et donnée pendant l'installation (__tout__ les iconsets seront installer)

si vous ne pouvez pas lancer install

```Shell
./install.sh
```

tapez

```Shell
sudo chmod 775 install.sh
```

## installation manuel

les dossier contenu dans le dossier Nagvis de ce git sont de la forme :
  [nom de l'iconset]_iconset
c'est dossier contiennent 1 set d'icone chacun pour nagvis

pour les installer (sur une installation ISO centreon) :
(Les chemin sont peut être différent sur vos machine mais le principe restent le même)

```shell
cd /usr/share/nagvis/share/userfiles/images/iconesets/
```

```shell
git clone https://github.com/rodeur2225/jubilant-garbanzo.git
```

```shell
mv jubilant-garbanzo/Nagvis/[nom de l'iconset]_iconset/*_* .
```
remplacer le [nom de l'iconset] par le nom de celui que vous souhaitez installer
repeter le mv pour chaque inconset que vous souhaitez installer

verfifer la présences des icones par un ls

n'oubliez pas de suprier jubilant-garbanzo quand vou aurez fini

__END__
