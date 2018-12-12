# VMware

## pas de reponse ou probleme de connexion avec les plugin vmware 

si la connection du plugin connecteur vmware est impossible ou bien si le plugin renvoie un timeout,

regarder si centreon vmware et configurer,

en effet il faut lui donner un accés au serveur vmwarepour pouvoir executer le plugin correctement

créé donc d'abord un compte pour centreon sur votre serveur vmware

et renseigner le fichier `/etc/centreon/centreon_vmware.pm`

```perl

%centreon_vmware_config = (
  vsphere_server => {
                  'default' => { 'url' => http://[monserveur] ,
                                 'username' => 'XXX' ,
                                 'password' => 'XXX' }
                  }
);

1;
```

ce fichier contient l'adresse du serveur et les informations de connexion du compte que vous avez créé pour centreon au serveur

__END__
