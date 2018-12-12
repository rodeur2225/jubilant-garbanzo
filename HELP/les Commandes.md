# Les Commandes 

pour cree les commande rien de plus simple regarder dans configuration -> commande -> check

comment sont ecrite les commande et chercher ensuite dans les plugin ce dont vous avez besoin

pour faciliter la tache allez dans la doc Centreon plugin pack (je l'ai ajouter sur la page principale de monitoring) et faite un `Ctrl+F` de ce dont vous avez besoins

connectez vous en SSH a centreon et allez dans /usr/lib/centreon/plugins

SI :
+ vous cherchez un plugin nagios (il sont dispo dans le git) le chemin sera plutot /usr/lib/nagios/plugin 
+ vous utilisez les plugin opensource de github tout en un le chemin sera /usr/lib/centreon/plugins/centreon-plugins
+ vous ete passez par le yum install centreon-* le chemin sera /usr/lib/centreon/plugins tout les plugin y seront en vrac

peut import la condition (sauf pour les nagios) les plugin s'utilise de la sorte
perl [nom_du_plugin].pl --plugin [chemin du plugin] --mode [nom du mode] --[parametre1] --[parametre2] --[parametre3] ...

vous pouvez cherche un plugin en tapant
perl [nom_du_plugin].pl --list-plugin
(conseil fait un | grep de ce que vous cherchez pour ne pas avoir une tros grande liste)

vous pouvez cherchez un mode en tapant 
perl [nom_du_plugin].pl --plugin [chemin du plugin] --list-mode

et vous pouvez obtenir des detail sur le fonctionnement et l'utilisation d'un certain en tapant
perl [nom_du_plugin].pl --plugin [chemin du plugin] --mode [nom du mode] --help

servez vous de ces informations pour créé vos commande sur centreon web

les paramètre seron données pars les macro centreon (elle commence et finissent par un $) comme 
$HOSTADRESS$ (ip de l'hoste)
$SNMPCOMMUNITY$ (communauté snmp de l'hote)
$SERVICEXTRAOPTION$ (permet de rejouter des bout de commande (lors de la creation d'un service) a une commande deja ecrite
et bien d'autre
sans oublier les arguments
$ARG1$ $ARG3$ $ARG3$ ...

une fois votre commande taper enregistrez la (une exporation de la configuration n'est pas nécéssaire

pour pouvoir utiliser efficacement cette commande il f'aut l'integrer a un template de service

allez dans configuration -> Services -> template

et cree une template utilisant votre commande (conseil donnez deja un nom des intervalle des notification et de check a ce template comme sa vous n'aurez plus a le faire quand vous cerez un srvice utilisant notre nouvelle commande)
