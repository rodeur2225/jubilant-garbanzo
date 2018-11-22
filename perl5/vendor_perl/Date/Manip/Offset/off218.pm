package #
Date::Manip::Offset::off218;
# Copyright (c) 2008-2013 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# This file was automatically generated.  Any changes to this file will
# be lost the next time 'tzdata' is run.
#    Generated on: Thu Sep  5 09:37:32 EDT 2013
#    Data version: tzdata2013d
#    Code version: tzcode2013d

# This module contains data from the zoneinfo time zone database.  The original
# data was obtained from the URL:
#    ftp://ftp.iana.orgtz

use strict;
use warnings;
require 5.010000;

our ($VERSION);
$VERSION='6.41';
END { undef $VERSION; }

our ($Offset,%Offset);
END {
   undef $Offset;
   undef %Offset;
}

$Offset        = '+10:00:00';

%Offset        = (
   0 => [
      'australia/melbourne',
      'australia/brisbane',
      'australia/lindeman',
      'pacific/port_moresby',
      'australia/currie',
      'australia/hobart',
      'australia/sydney',
      'pacific/chuuk',
      'pacific/guam',
      'pacific/saipan',
      'asia/yakutsk',
      'asia/vladivostok',
      'asia/sakhalin',
      'etc/gmt+10',
      'w',
      'antarctica/dumontdurville',
      'asia/magadan',
      'australia/lord_howe',
      'australia/broken_hill',
      'antarctica/macquarie',
      'asia/khandyga',
      'asia/ust-nera',
      ],
   1 => [
      'asia/yakutsk',
      'asia/choibalsan',
      'asia/vladivostok',
      'asia/seoul',
      'asia/tokyo',
      'asia/khandyga',
      ],
);

1;
