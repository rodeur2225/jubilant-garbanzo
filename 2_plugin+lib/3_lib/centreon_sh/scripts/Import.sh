#!/bin/bash

# ######################################
# Autheur : Thibaut Depond
# Date : 11/12/2018
# Importe la configuration de centreon 
# ######################################

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

if [ $1 == NULL ];then
	echo "erreur aucun paramètre aucune config a importer"
	exit $STATE_CRITICAL
fi

/bin/centreon -u admin -p stage2018 -i $1

if [ $? -eq 1 ];then
	echo "command failed"
	exit $STATE_CRITICAL
fi

echo "import ok verifier sur centreon web"
exit $STATE_OK
