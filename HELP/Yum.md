# YUM

## erreur 404 
si yum renvoie une erreure __404__ c'est potentiellement a cause du cache qu'il accumule

pour  arranger ça :
```Shell
yum clean all 
rm -rf /var/cache/yum 
```
> (nettoie le cache de yum)
> (supprime le dossier de chache de yum ,permet de se débarraser des orphelins)

si cela ne fonctionne toujours pas et que les repo sont indsponible

faite un `vim de /etc/yum.conf`

ajouter la ligne suivante :

http_caching=packages

pour verifier si sa fonctionne a nouveau faite un `yum update`

Enfin si cela ne fonctionne toujours pas verifier votre conexions internet.

__END__
