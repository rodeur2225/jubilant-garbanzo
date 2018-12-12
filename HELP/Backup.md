# les Backups

### notre centreon peut etre équipé de trois systeme de backup :

#### le backup integre a centreon (voir la [doc](https://documentation-fr.centreon.com/docs/centreon/en/18.10/administration_guide/backup.html#sauvegarde-de-la-plate-forme))

#### Centreon-awie 

c'est un module permettant de genere une archive zip de lq config de centreon (les host les service ...)
  
voir le github de centreon dans la section [centreon-awie](https://github.com/centreon/centreon-awie) (et la doc [awie](https://documentation.centreon.com/docs/centreon-awie/en/1.0.x/))

> il peut être installer via yum
  
#### le CLAPI

il existe une commande bash de centreon qui permet de cree une copie de la config (comme awie) mais au format txt

pour exporter la configuration il suffit de taper (depuis le /bin):

```Shell
./centreon -u admin -p centreon -e > /tmp/clapi-export.txt
```

pour importer :

```Shell
./centreon -u admin -p centreon -i /tmp/clapi-export.txt
```

##### NOTE : 
pour le clapi j'ai ecri un plugin qui permet donc depuis centreon d'automatiser la backup
pour pouvoir l'utiliser il suffit d'installer le [2_plugin+lib](https://github.com/rodeur2225/jubilant-garbanzo/blob/master/INSTALL/2_plugin%2Blib.md)
    
et cree la commande suivante depuis centreon web :

```Shell
perl /usr/lib/centreon/plugins/centreon-plugins/centreon_plugins --plugin other::eximport::plugin --mode export
```

cette command cree un .txt de votre config (pas plus de un par jour !si vous essayer de faire pluys cela va juste ecraser le dernier) 
et le range dans /tmp/clapi-export (pas la peine de cree le dossier le plugin le fera de lui meme.
      
 __END__
