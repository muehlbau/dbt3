#!/usr/bin/perl -w
#
# get_power.sh: get dbt3 query process power
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003-2006 Open Source Development Labs, Inc.
#
# Author: Jenny Zhang
#

use strict;
use Pod::Usage;
use Getopt::Long;

=head1 NAME

get_power.pl

=head1 SYNOPSIS
calculate the power metrics

=head1 ARGUMENTS

 -perf_run_number <perf_run_number>
 -scale_factor <scale factor >
 -file <config filename to read from> 
 -write <config filename to write to> 
 -z

=cut

my ($perf_run_number, $hlp, $infile, $scale_factor, $configfile,
  $power, @power_query, @power_refresh, $i, $no_refresh);

GetOptions(
  "perf_run_number=i" => \$perf_run_number,
  "scale_factor=f" => \$scale_factor,
  "help"      => \$hlp,
  "infile=s"  => \$infile,
  'z'         => \$no_refresh
);


if ($hlp) {
  pod2usage(1);
}

my $value = 1;

#
# Get execution time for the power queries.
#
for ($i = 1; $i <= 22; $i++) {
  my $val = `grep \'PERF$perf_run_number.POWER.Q$i \' $infile | awk '{ print \$11 }'`;
  chomp $val;
  $value *= $val;
}

#
# Get execution time for the power refresh functions.
#
unless ($no_refresh) {
  for ($i = 1; $i <= 2; $i++) {
    my $val = `grep \'PERF$perf_run_number.POWER.RF$i\' $infile | awk '{ print \$11 }'`;
    #
    # Skip in case the refresh functions finished within 1 second so we don't
    # get a divide by 0 error later.
    #
    if ($val == 0) {
      next;
    }
    chomp $val;
    $value *= $val;
  }
}

$power = (3600 * $scale_factor) / ($value)**(1/24);
print "$power\n";

exit 0;
