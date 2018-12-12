# Centreon Web

## exportation de la configuration 

aprés avoir :
- ajouter un hote/service
- supprimer un hote/service
- modifier un hote/service

tout autre travail sur centreon ne **nécéssite pas** une exportation

rendez vous dans configuration->pollers->poller

cliquez sur le bouton exporter la configuration

puis sur la page qui apparait fait ceci:

###### étape 1 :

Poller [Central]

- [x] Generate Configuration Files
- [x] Run monitoring engine debug
- [ ] Move Export File
- [ ] Restart Monitoring engine [Reload]

appuyer sur export et verifier les erreurs

###### étape 2 :

Poller [Central]

- [ ] Generate Configuration Files
- [ ] Run monitoring engine debug
- [x] Move Export File
- [x] Restart Monitoring engine [Reload]

appuyer sur export 

la configuration est exporté revener sur la page de monitoring pour voir les effets 

(les bulles d'info en haut de l'écran ne s'actualise pas immédiatement aprés l'exportation rafraichisser la page (f5) 
pour voire les modifications) 

## la configuration n'est pas exporter 
quand votre configuration n'est pas visible dans la partie monitoring c'est qu'elle na pas été exporter

rendez vous dans l'interface en ligne de commande de centreon (accessible via ssh) et taper :

```Shell
systemctl restart cbd
```

(a pour effet de redémarrer centreon broker)

si cela ne fonctionne pas verifier c'est différent élément toujours via le terminal :

```Shell
service centcore status 
```

```Shell
service centengine status 
```

```Shell
service cbd status 
```

si certain ne sont pas actif verifier leur log (les commande precedente indique comment acceder aux log)

```Shell
netstat -plant | grep 5669 
```
vérifie les connexion tcp, regardez si le cbd est sur **LISTEN**

## les service supprimé apparaissent toujours 

il arrive que quand on renomme ou on supprime un service il ne soit plus reconnu par centreon mais reste afficher 
sur les fenetre de monitoring,

pour supprimer ce doublon ou reminiscence

rendez vous dans configuration->pollers->poller

cliquez sur le bouton exporter la configuration

puis sur la page qui apparait fait ceci:

Poller [Central]

- [ ] Generate Configuration Files
- [ ] Run monitoring engine debug
- [ ] Move Export File
- [x] Restart Monitoring engine [**Restart**]

appuyer sur export

Si cela ne fonctionne pas refaite un exportation complète :

Poller [Central]

- [x] Generate Configuration Files
- [x] Run monitoring engine debug
- [x] Move Export File
- [x] Restart Monitoring engine [**Restart**]

appuyer sur export

## Central not runing 
quand l'icone est Rouge en haut a gauche de l'écran cela signifie que le collecteur ne fonctionne pas (not running) 
les données de monitoring ne se mettent donc plus a jour.

pour regler cela vous pouvez essayer tout d'abord de [**Restart**] vu juste au dessus,

sinon rendez vous dans l'interface en ligne de commande de centreon (accessible via ssh) et taper :

```Shell
systemctl restart cbd 
```

ceci a pour effet de redémarrer centreon broker.

## l'exportation de la configuration reste a __0%__ 
si cela arrrive :
+ changez de navigateur
+ ou vider le cache de votre navigateur actuel
+ si les 2 options du dessus ne fonctionne pas redemarrer centreon broker (vu juste au dessus)

__END__
