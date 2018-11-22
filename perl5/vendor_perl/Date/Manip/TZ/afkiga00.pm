package #
Date::Manip::TZ::afkiga00;
# Copyright (c) 2008-2013 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Thu Sep  5 09:35:20 EDT 2013
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
        [ [1,1,2,0,0,0],[1,1,2,2,0,16],'+02:00:16',[2,0,16],
          'LMT',0,[1935,5,31,21,59,43],[1935,5,31,23,59,59],
          '0001010200:00:00','0001010202:00:16','1935053121:59:43','1935053123:59:59' ],
     ],
   1935 =>
     [
        [ [1935,5,31,21,59,44],[1935,5,31,23,59,44],'+02:00:00',[2,0,0],
          'CAT',0,[9999,12,31,0,0,0],[9999,12,31,2,0,0],
          '1935053121:59:44','1935053123:59:44','9999123100:00:00','9999123102:00:00' ],
     ],
);

%LastRule      = (
);

1;
