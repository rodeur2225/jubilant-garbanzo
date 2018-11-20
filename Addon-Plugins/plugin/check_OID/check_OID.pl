#!/usr/bin/perl
#============================================
# Auteur : Rod'n
# Date   : 21/11/18
# But    : lecture d'OID
#============================================
use strict;
use warning;
use Monitoring::Plugin;

my $np = Monitoring::Plugin->new;

$np->plugin_exit( OK, "OK");

__END__ 