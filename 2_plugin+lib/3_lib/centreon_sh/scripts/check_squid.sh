#!/bin/sh
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# This script will get some performance information from a Squid cache
# It also lets you set the warning and critical levels for the remaining file descriptors

PROGNAME=`basename $0`
VERSION="Version 0.1"
AUTHOR="Ken Murphy (murphyk@ainfosec.com)"

#DEFINES
ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3
#VARS
hostname="localhost"
port=80
running=0
warn_descriptors=100
crit_descriptors=30

print_version() {
	echo "$PROGNAME $VERSION $AUTHOR"
}

print_help() {
	print_version
	echo ""
	echo "Description:"
	echo "Gets various performance metrics for a squid reverse proxy"
	echo "Options:"
	echo "  -H|--hostname)"
	echo "   Sets the hostname, default is localhost"
	echo "  -P|--port)"
	echo "   Sets the port, default is 80"
	echo "  -wd)"
	echo "   Sets the number of available file descriptors to warn at, default 100"
	echo "  -cd)"
	echo "   Sets the number of available file descriptors to go critical at, default 30"
	echo "\n"
	exit $ST_UK
}

#the call to get all the information
get_status_text() {
	status_text=`squidclient -h ${hostname} -p ${port} mgr:info 2>&1`
} 

#make sure the server is replying properly
is_replying() {
	#up=`echo "${status_text}" | grep "Access Denied."`
	case "$status_text" in
		*Denied.*)
			echo "Error gettings metrics.(Access control on squid?)"
			exit $ST_CR
			;;
		*ERROR*)
			echo "Error connecting to host"
			exit $ST_CR
			;;
	esac
}

#this will get the relevant information for us from that huge output block and store it
#interested in: 
#Available file descriptors
#CPU Usage
#Average HTTP requests per minute
get_statistics() {
	available_descriptors=`echo "${status_text}" | grep "Available number of file descriptors" | cut -d: -f 2 | sed -e 's/^[ \t]*//'`
	cpu_usage=`echo "${status_text}" | grep "CPU Usage:" | cut -d: -f2 | cut -d% -f 1 | sed -e 's/^[ \t]*//'`
	avg_http_requests=`echo "${status_text}" | grep "Average HTTP requests per minute since start" | cut -d: -f2 | cut -d% -f 1 | sed -e 's/^[ \t]*//'` 
	#buid perfdata string
	perfdata="'avail_descriptors'=$available_descriptors 'cpu_usage'=$cpu_usage 'avg_http_requests'=$avg_http_requests"
}

#builds and output the output string
build_output() {
	out="Squid is serving an average of $avg_http_requests per minute since start with $available_descriptors file descriptors left and $cpu_usage percent of CPU use"
	if [ $available_descriptors -le $crit_descriptors ]
	then
		echo "CRITICAL - ${out} | ${perfdata}"
		exit $ST_CR
	elif [ $available_descriptors -le $warn_descriptors ]
	then
		echo "WARNING - ${out} | ${perfdata}"
		exit $ST_WR
	else
		echo "OK - ${out} | ${perfdata}"
		exit $ST_OK
	fi
}
#MAIN
#get arguments
while test -n "$1"; do
	case "$1" in
		--help|-h)
			print_help
			exit $ST_UK
			;;
		--version|-v)
			print_version
			exit $ST_UK
			;;
		--hostname|-H)
			hostname=$2
			shift
			;;
		--port|-P)
			port=$2
			shift
			;;
		-wd)
			warn_descriptors=$2
			shift
			;;
		-cd)
			crit_descriptors=$2
			shift
			;;
		*)
			echo "Unknown argument: $1"
			print_help
			exit $ST_UK
			;;	
	esac
	shift
done
#sanity
if [ $warn_descriptors -lt $crit_descriptors ]
then
   echo "Warn value must not be lower than critical value!"
   print_help
fi

get_status_text
is_replying
get_statistics
build_output
