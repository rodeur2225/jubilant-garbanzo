# Centreon

## les mises a jour 
il suffit de suivre la documentation elle est suffisament claire pour être suivi à la lettre,

__MAIS__ si lors de la mise a jour des package on obtient une erreur (en generale une erreur __404__) faite ceci :
```Shell
yum clean all
rm -rf /var/cache/yum/*
```
et relancer la mise a jour de centreon avec:
```Shell
yum update centreon*
```

aprés la mise ajour vérifier si les syntaxes de vos commande son encore compatible ,verifier aussi les chemin d'accés 
dans Configuration->poller->resources
