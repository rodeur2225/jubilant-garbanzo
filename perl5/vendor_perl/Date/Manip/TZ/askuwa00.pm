package #
Date::Manip::TZ::askuwa00;
# Copyright (c) 2008-2013 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Thu Sep  5 09:35:07 EDT 2013
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
        [ [1,1,2,0,0,0],[1,1,2,3,11,56],'+03:11:56',[3,11,56],
          'LMT',0,[1949,12,31,20,48,3],[1949,12,31,23,59,59],
          '0001010200:00:00','0001010203:11:56','1949123120:48:03','1949123123:59:59' ],
     ],
   1949 =>
     [
        [ [1949,12,31,20,48,4],[1949,12,31,23,48,4],'+03:00:00',[3,0,0],
          'AST',0,[9999,12,31,0,0,0],[9999,12,31,3,0,0],
          '1949123120:48:04','1949123123:48:04','9999123100:00:00','9999123103:00:00' ],
     ],
);

%LastRule      = (
);

1;
