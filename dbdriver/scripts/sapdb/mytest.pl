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
use Env qw(SID DBT3_PERL_MODULE DBUSER);
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
my (@tmp_power_query, @tmp_power_refresh);
for ($i=1; $i<=22; $i++)
{
	$tmp_power_query[$i] = `dbmcli -d $SID -u dbm,dbm -uSQL $DBUSER,$DBUSER "sql_execute select (e_time-s_time) as diff_time from time_statistics where task_name='PERF$perf_run_number.POWER.Q$i';"|grep -v row|grep -v diff`;
	$tmp_power_query[$i] =~ s/-*//;
	chop($tmp_power_query[$i]);
	$power_query[$i]=convert_to_seconds($tmp_power_query[$i]);
}
