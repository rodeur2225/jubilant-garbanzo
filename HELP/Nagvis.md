# Nagvis

## même apres installation complete nagvis n'apparait dans centreon web
retournez sur le site d'aide a l'[installation de nagvis](http://www.sugarbug.fr/atelier/techniques/ihmweb/cartographie_supervision/centreon-web28x_nagvis-19x/)

au niveau de la modification du fichier __sql__ contentez vous le recopiez a la lettre prés même si cela implique de supprimé le contenu initiale du fichier.
aprés cela essayer de desintaller et de reinstaller le module nagvis depuis l'interface web centreon, les onglets nagvis devrait apparaitre

par contre ces onglets serons surement vide a cause de probleme de compatibilité php 
> {pas encore de solution aujourd'hui le 13/12/18 pour centreon 18.10}

## erreur de suppression de carte dans nagvis
il arrive que la suppression de carte ne se deroule pas comme prévue dans nagvis et que votre carte sois rester affiché 
sois provoque une erreur qui est iréparable __depuis__ l'interface web de nagvis 

pour corriger cela faite un `locate` du nom de votre carte dans le terminal,

et supprimer manuellement tout les fichier contenant le nom de votre carte,

(verifier quand même que ces fichier que vous comptez supprimer __appartiennent__ au dossier nagvis)
