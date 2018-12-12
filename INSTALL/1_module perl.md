# installation de module perl

__l'installation de ces modules n'est nécessaire que si vous ne passer pas du tout par l'install par yumdes plugins__

au prélable si vous ne l'avez pas encore fais tapez ces commande :
  + cpan app::cpanminus (en premier c'est trés important sinon vous ne pourrez **PAS** executez les autres)
  + cpanm Module::Install::AuthorTests
  + cpanm Module::Install::CheckLib
  + cpanm Module::Install::XSUtil
  + cpanm Test::Fatal
  + cpanm Test::Requires
  + cpanm Test::TCP
  + cpanm Devel::CheckLib
  
  (ces module sont nécessaire a l'installation et au test de certain autres module s'il ne sont pas présent il vous serons demandez ou provoquerons un erreurs)

_**!!** si vous avez fais l'installation complete celon le sacro saint yum cette installation est inutile **!!**_

### pour le plugin VMWARE 

ce plugin est disponible via yum pour l'installer taper ces commandes :

```Shell
yum install centreon-plugin-Virtualization-VMWare-deamon.noarch
yum install centreon-plugin-Virtualization-VMWare2-Connector-plugin.noarch
yum install centreon-plugin-Virtualization-VMWare2-Esx-Wsman.noarch

```

sinon si vous souhaitez l'instellez vous même le plugin est dispo dans centreon-plugins mais nécéssite que l'on lui installe des librairie

voici l'ordre d'installation :

###### ZMQ :
  + libzmq-master.zip
  
    l'installation de cette librairie est faite dans /usr/local/lib un fois l'installation realisé taper cette commande
    
    ```Shell
    mv /usr/local/lib/libzmq.so.5* /usr/lib64
    ```
    
  + LibZMQ4
  
###### uuid :
  + uuid-1.6.2-26.el7.x86_64.rpm	
  + uuid-devel-1.6.2-26.el7.x86_64.rpm
  + uuid-perl-1.6.2-26.el7.x86_64.rpm
  + pour completer l'installation du module UUID pour perl taper ceci :
    + yum install libuuid libuuid-devel
    + yum install glibc
    + cpanm UUID



__END__
