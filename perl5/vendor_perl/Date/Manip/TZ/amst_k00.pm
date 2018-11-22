package #
Date::Manip::TZ::amst_k00;
# Copyright (c) 2008-2013 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Thu Sep  5 09:35:06 EDT 2013
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
        [ [1,1,2,0,0,0],[1,1,1,19,49,8],'-04:10:52',[-4,-10,-52],
          'LMT',0,[1912,3,2,4,10,51],[1912,3,1,23,59,59],
          '0001010200:00:00','0001010119:49:08','1912030204:10:51','1912030123:59:59' ],
     ],
   1912 =>
     [
        [ [1912,3,2,4,10,52],[1912,3,2,0,10,52],'-04:00:00',[-4,0,0],
          'AST',0,[9999,12,31,0,0,0],[9999,12,30,20,0,0],
          '1912030204:10:52','1912030200:10:52','9999123100:00:00','9999123020:00:00' ],
     ],
);

%LastRule      = (
);

1;
