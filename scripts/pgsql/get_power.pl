#!/usr/bin/perl -w
#
# get_power.sh: get dbt3 query process power
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
use strict;
use Pod::Usage;
use FileHandle;
use Getopt::Long;
use Env qw(SID DBT3_PERL_MODULE PGUSER);
use lib "$DBT3_PERL_MODULE";
use Data_report;

=head1 NAME

get_power.pl

=head1 SYNOPSIS
calculate the power metrics

=head1 ARGUMENTS

 -perf_run_number <perf_run_number>
 -scale_factor <scale factor >
 -file <config filename to read from> 
 -write <config filename to write to> 

=cut

my ( $perf_run_number, $hlp, $scale_factor, $configfile, $writeme, 
	$power, @power_query, @power_refresh, $i );

GetOptions(
	"perf_run_number=i" => \$perf_run_number,
	"scale_factor=f" => \$scale_factor,
	"help"      => \$hlp,
	"file=s"    => \$configfile,
	"write=s"   => \$writeme
);


my $fcf = new FileHandle;
my ( $cline, %options );

if ($hlp) { pod2usage(1); }

if ( $configfile ) {
	unless ( $fcf->open( "< $configfile" ) ) {
		die "Missing config file $!";
	}
	while ( $cline = $fcf->getline ) {
		next if ( $cline =~ /^#/ );
		chomp $cline;
	my ( $var, $value ) = split /=/, $cline;
		$options{ $var } = $value;
	}
	$fcf->close;
}

if ( $perf_run_number ) { $options{ 'perf_run_number' } = $perf_run_number; }
elsif ( $options{ 'perf_run_number' } ) {
        $perf_run_number =  $options{ 'perf_run_number' };
}
else
{
        die "No perf_run_number $!";
}

if ( $scale_factor ) { $options{ 'scale_factor' } = $scale_factor; }
elsif ( $options{ 'scale_factor' } ) {
        $scale_factor =  $options{ 'scale_factor' };
}
else
{
        die "No scale_factor $!";
}

if ( $writeme ) {
	my $ncf = new FileHandle;
	unless ( $ncf->open( "> $writeme" ) ) { die "can't open file $!"; }
	my $name;
	foreach $name ( keys( %options ) ) {
	    print $ncf $name, "=", $options{ $name }, "\n";
	}
	$ncf->close;
}

# get execution time for the power queries
for ($i=1; $i<=22; $i++)
{
	$power_query[$i] = `psql -t -d $SID -c "select (extract(hour from (e_time-s_time)) * 3600) + (extract(minute from (e_time-s_time)) * 60) + (extract(second from (e_time-s_time))) as seconds from time_statistics where task_name='PERF$perf_run_number.POWER.Q$i';"`;
	chomp($power_query[$i]);
	chomp($power_query[$i]);
}

# get execution time for the power refresh functions
for ($i=1; $i<=2; $i++)
{
	$power_refresh[$i] = `psql -t -d $SID -c "select (extract(hour from (e_time-s_time)) * 3600) + (extract(minute from (e_time-s_time)) * 60) + (extract(second from (e_time-s_time))) as seconds from time_statistics where task_name='PERF$perf_run_number.POWER.RF$i';"`;
        chomp($power_refresh[$i]);
        chomp($power_refresh[$i]);
	# in case the refresh functions finished within 1 second
	if ( $power_refresh[$i] == 0 ) { $power_refresh[$i] = 1; }
}

my $tmp_query = 1;
for ( $i=1; $i<=22; $i++ )
{
	$tmp_query = $power_query[$i] * $tmp_query;
}
my $tmp_refresh = 1;
for ( $i=1; $i<=2; $i++ )
{
	$tmp_refresh = $power_refresh[$i] * $tmp_refresh
}

$power = (3600 * $scale_factor) / ($tmp_query * $tmp_refresh)**(1/24);
printf "power = %.2f\n", $power;
