# installation de module perl

au prélable si vous ne l'avez pas encore fais tapez ces commande :
  cpan app::cpanminus
  cpanm Module::Install::AuthorTests
  cpanm Module::Install::CheckLib
  cpanm Module::Install::XSUtil
  cpanm Test::Fatal
  cpanm Test::Requires
  cpanm Test::TCP
  cpanm Devel::CheckLib
  (ces module sont nécessaire a l'installation et au test de certain autres module s'il ne sont pas présent il vous serons demandez ou provoquerons un erreurs)

!! si vous avez fais l'installation complete celon le sacro saint yum cette installation est inutile !!

### pour le plugin VMWARE

voici l'ordre d'installation :

ZMQ :
  + libzmq-master.zip
    (l'installation de cette librairie est faite dans /usr/local/lib un fois l'installation realisé taper cette commande
     mv /usr/local/lib/libzmq.so.5* /usr/lib64 )
  + LibZMQ4
  
uuid :
  + uuid-1.6.2-26.el7.x86_64.rpm	
  + uuid-devel-1.6.2-26.el7.x86_64.rpm
  + uuid-perl-1.6.2-26.el7.x86_64.rpm
  + pour completer l'installation du module UUID pour perl taper ceci :
    + yum install libuuid libuuid-devel
    + yum install glibc
    + cpanm UUID

/*---


__END__
