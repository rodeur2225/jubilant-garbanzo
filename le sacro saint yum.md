# Le Sacro-Saint YUM

yum est l'installateur de paquet de CentOS

## installer tout centreon avec yum
quasiment tout les plugins widgets et modules (même ceux inutile ou incomplet __attention__) de centreon peuvent être installer en une seul commande,
en réalisant un 
```Shell
yum search centreon
```
on peut voir tout les paquets disponible pour centreon

_**!!** le paquet de debuginfo pour **nrpe3** n'est pas signé il fera planter l'installation des autres paquets **!!**_

pour tout installer taper

```Shell
yum install -y --exclude=*nrpe3* centreon-*
```
  -y repond oui automatiquement au question d'installation (pas d'inquiétude il n'y pas de danger a repondre oui a tout)
  --exclude=regexp permet d'exclure de l'installation tout les paquet correspondant a l'expression reguliere
      (ici on exclu nrpe)
  si vous ne voulez pas le detail de l'installation vous pouvez rajoutez -q (quiet) pour activer l'installation silencieuse
  
l'installation par yum permet de gerer **automatiquement les probleme de dépendance** car yum ira lui-m$eme cherchez les paquets nécéssaire 

Néanmoins prenez garde en installant tout car certain modules ou widget ou autre sont soit **inutile imcomplet ou obsolete** donc chercher ce dont **VOUS avez besoin** pour centreon

un **MUST** a avoir est :
+ mlocate (permet de localiser des fichier)
  (la commande locate execute une recherche dans sa base de donné lancer updatedb a l'installation de mlocate et aprés de grosse modification dans l'arborescence de votre machine)
+ vim (un editeur avec une coloration syntaxique pratique mais pas obligatoire)
+ git (obligatoire pour faire les install)
+ unzip (permet de dezipper les .zip {qui ne sont normalement pas pris en charge par UNIX})
+ centreon-awie (module centreon qui permet d'importer et d'exporter tout ce que vous avez fais sur centreon web)

ces paquet peuvent s'averez trés utile, ceci est un conseil
  
si vous rencontrez des probleme avec yum tel q'une erreur 404 referez vous au fichier [/HELP/Yum.md](https://github.com/rodeur2225/jubilant-garbanzo/blob/master/HELP/Yum.md)
