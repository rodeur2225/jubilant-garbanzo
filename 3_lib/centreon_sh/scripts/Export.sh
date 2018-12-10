#!/bin/bash

# ##############################################################
# Autheur : Thibaut Depond
# Date : 10/12/2018
# Export la configuration de centreon et en verfie la réussite
# ##############################################################

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

d=$(date +%d%B%Y)
p="/tmp/clapi-export/export"
e=".txt"

if [ ! -d "/tmp/clapi-export" ];then
	mkdir /tmp/clapi-export
fi

/bin/centreon -u admin -p stage2018 -e > $p$d$e

if [ -f $p$d$e ];then
	echo $STATE_OK
	exit $STATE_OK
else
	echo $STATE_CRITICAL
	exit $STATE_CRITICAL
fi
