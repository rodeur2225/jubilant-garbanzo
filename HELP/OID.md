# OID

## un oid que vous recuperez sur le net ne fonctionne pas
+ verfier deja que vous utiliser le bon plugin (NB : passez par les plugin nagios fournie dans ce git) il y a trois type de valeur d'OID:
  + string (chaine de charactère)
  + value (une valeur numérique)
  + table (un tableau de valeur numerique/string)

+ __sinon__, prenons pour exemple le 1.3.6.1.2.1.1.1 essayer : 
  + soit de mettre un **point** devant : .1.3.6.1.2.1.1.1 
  + soit de mettre un **.0** a la fin : 1.3.6.1.2.1.1.1.0 
  + soit les **deux** : .1.3.6.1.2.1.1.1.0

si cela ne fonctionne toujours verifez que votre appareil accepte les requêtes snmp
verifiez aussi que vous avez interroger le bonne OID chaque machine peut avoir ces propore OID

_pour info :_
la plupart des [entreprise du domain de l'informatique](https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers) possède une branche du [repertoire OID](http://www.oid-info.com/),

ils ont donc des OID spécifique qui correspondent a leur machine et aucune autre.

> par exemple l'OID des ventilateur qui fonctionne avec un __hp__ ne fonctionnera pas avec un __cisco__.

__END__
