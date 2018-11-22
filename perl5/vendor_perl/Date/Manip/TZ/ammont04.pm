package #
Date::Manip::TZ::ammont04;
# Copyright (c) 2008-2013 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Thu Sep  5 09:35:27 EDT 2013
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
        [ [1,1,2,0,0,0],[1,1,1,19,51,8],'-04:08:52',[-4,-8,-52],
          'LMT',0,[1911,7,1,4,9,51],[1911,7,1,0,0,59],
          '0001010200:00:00','0001010119:51:08','1911070104:09:51','1911070100:00:59' ],
     ],
   1911 =>
     [
        [ [1911,7,1,4,9,52],[1911,7,1,0,9,52],'-04:00:00',[-4,0,0],
          'AST',0,[9999,12,31,0,0,0],[9999,12,30,20,0,0],
          '1911070104:09:52','1911070100:09:52','9999123100:00:00','9999123020:00:00' ],
     ],
);

%LastRule      = (
);

1;
