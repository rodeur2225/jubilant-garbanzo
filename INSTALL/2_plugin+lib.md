# Installation de plugin et de script pour centreon

## l'install

dans le dossier 2_plugin+lib il y a un fichier install.sh lancez le et vous n'aurez plus rien a faire le detail de l'installation et donnée pendant l'installation

si vous ne pouvez pas lancer install

```Shell
./install.sh
```

tapez

```Shell
sudo chmod 775 install.sh
```

## aprés l'installation 
les éléments ce trouve dans :
 + (centreon-plugins) /usr/lib/centreon/plugins
 + (nagios) /usr/lib
 + (centreon_sh) /usr/lib
 + (other) /usr/lib/centreon/plugins/centreon-plugins
 
 _si l'intall ne fonctionne pas je vous invite a lire install.sh les commande utilisé sont les commande basique de bash,cette installation ne fait qu'importer centreon-plugins de github et le deplace ensuite avec tout le reste du fichier dans votre arborescence_
 
 __END__
