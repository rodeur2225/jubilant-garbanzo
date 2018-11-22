package #
Date::Manip::TZ::afkins00;
# Copyright (c) 2008-2013 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Thu Sep  5 09:35:04 EDT 2013
#    Data version: tzdata2013d
#    Code version: tzcode2013d

# This module contains data from the zoneinfo time zone database.  The original
# data was obtained from the URL:
#    ftp://ftp.iana.org/tz

use strict;
use warnings;
require 5.010000;

our (%Dates,%LastRule);
END {
   undef %Dates;
   undef %LastRule;
}

our ($VERSION);
$VERSION='6.41';
END { undef $VERSION; }

%Dates         = (
   1    =>
     [
        [ [1,1,2,0,0,0],[1,1,2,1,1,12],'+01:01:12',[1,1,12],
          'LMT',0,[1897,11,8,22,58,47],[1897,11,8,23,59,59],
          '0001010200:00:00','0001010201:01:12','1897110822:58:47','1897110823:59:59' ],
     ],
   1897 =>
     [
        [ [1897,11,8,22,58,48],[1897,11,8,23,58,48],'+01:00:00',[1,0,0],
          'WAT',0,[9999,12,31,0,0,0],[9999,12,31,1,0,0],
          '1897110822:58:48','1897110823:58:48','9999123100:00:00','9999123101:00:00' ],
     ],
);

%LastRule      = (
);

1;
