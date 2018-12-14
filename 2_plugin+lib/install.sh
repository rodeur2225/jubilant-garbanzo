#!/bin/bash
echo  "installation des plugins centreon open source + ajout de plugin perso + installation des script necessaire + installation des plugins nagios"
echo "installation de centreon plugins"
if [ ! -d /usr/lib/centreon/plugins/centreon-plugins ];then
	git clone http://github.com/rodeur2225/centreon-plugins.git
	if [ $? != 0 ];then
		echo "errue d'installation verifier votre conexion internet"
		exit 2
	fi
	false
	chmod 775 ./centreon-plugins/centreon_plugins.pl
	echo "installation de du package de plugin other (plugin perso)"
	mv -f ./2_other/* ./centreon-plugins/other
	mv -f ./centreon-plugins /usr/lib/centreon/plugins
else
	if [ -d /usr/lib/centreon/plugins/centreon-plugins/other ];then
		rm -rf /usr/lib/centreon/plugins/centren-plugins/other
		mv -f ./2_other /usr/lib/centreon/plugins/centreon-plugins/other
	fi		
fi
	
echo -e "les plugins other sont installer dans centreon-plugins \nles voici :"
perl /usr/lib/centreon/plugins/centreon-plugins/centreon_plugins.pl --list-plugin | grep other
echo "tapez <entrer> pour continuer"
read touch
echo "centreon-plugins est installe dans /usr/lib/centreon/plugins"
echo "installation des scripts et plugins nagios"
if [ -d /usr/lib/centreon_sh ];then
	rm -rf /usr/lib/centreon_sh
fi
if [ -d /usr/lib/nagios ];then 
	rm -rf /usr/lib/nagios
fi
mv ./3_lib/* /usr/lib
echo -e "les scripts sont installé dans /usr/lib/centreon_sh\nles plugins nagios sont installés dans /usr/lib/nagios"
echo "installation terminé n'oublier pas de supprimer jubilant-garbanzo quand vous aurez fini"
cd
