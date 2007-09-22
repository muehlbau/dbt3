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

$scale_factor ||= 1; 
$perf_run_number ||= 1;

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
my $no_of_queries = 0 ; 

open(INFILE,"<$infile");
foreach (<INFILE>) { 
  chomp(); 
  s/^\s+//;
  s/\s+$//;
  my @vals; 
  my $val=0;
  # Get execution time for the power queries.
  if (/PERF$perf_run_number.POWER.Q\d+/) { 
    @vals = split(' ');
  } 
  # Get execution time for the power refresh functions.
  unless ($no_refresh) { 
    if (/PERF$perf_run_number.POWER.RF\d+/) { 
      @vals = split(' ');
    }
  }

  $val = $vals[5] || 0;
  if ($val && ($val != 0))  {
    $no_of_queries++;
    $value *= $val; 
  } 
}
close(INFILE);

$power = (3600 * $scale_factor) / ($value)**(1/$no_of_queries);
print "$power\n";

exit 0;
