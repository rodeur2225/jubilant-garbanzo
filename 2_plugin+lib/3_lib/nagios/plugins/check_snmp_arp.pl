#!/usr/bin/perl

########################
#
# Check number of arp-entries on a network device, i.e. a checkpoint firewall, that has default max 1024 arp enries
# Jon Ottar Runde, jru@rundeconsult.no
# http://www.rundeconsult.no/?p=88
# This requires snmpwalk and bc to work...
# Feel free to add proper snmp-perl-module support :)
#
########################

use strict;
use vars qw($opt_h $opt_H $opt_C $opt_w $opt_c $arp $OUTPUT);
use Getopt::Std;

&getopts("h:H:C:w:c:")||die "ERROR: Unknown Option, try -h for help\n";
if ($opt_h) {
    &print_usage;
   }

if (!defined($opt_H) || !defined($opt_C) || !defined($opt_w) || !defined($opt_c)) {
    &print_usage;
   }

sub print_usage {
    print "check_snmp_arp -H [ IP|HOSTNAME ] -C SNMPCOMMUNITY -w warning -c critical\n";
    exit 3;
}

$arp=`snmpwalk -v 1 -c $opt_C $opt_H 1.3.6.1.2.1.4.22.1.2|wc -l`;
chomp $arp;

$OUTPUT="Arp enries in memory: $arp |arp=$arp";
if ( $arp > $opt_c ) {
    print "Status is CRITICAL: $OUTPUT\n";
    exit 2;
   }
if ( $arp > $opt_w ) {
    print "Status is WARNING: $OUTPUT\n";
    exit 1;
   }
else {
    print "Status is OK. $OUTPUT\n";
    exit 0;
    }

