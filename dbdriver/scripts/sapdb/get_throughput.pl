#!/usr/bin/perl -w
#
# get_throughput.pl: get dbt3 throughput metrics
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
use strict;
use SAP::DBTech::dbm;
use Pod::Usage;
use FileHandle;
use Getopt::Long;
use Env qw(DBT3_INSTALL_PATH SID DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE/Sapdbpms";
use DBM::Exe_dbm_cmds;

=head1 NAME

get_throughput.pl

=head1 SYNOPSIS
calculate the throughput metrics

=head1 ARGUMENTS

 -perf_run_number <perf_run_number>
 -scale_factor <scale factor >
 -num_of_streams <number of streams >
 -file <config filename to read from> 
 -write <config filename to write to> 

=cut

my ( $perf_run_number, $hlp, $scale_factor, $num_of_streams, $configfile, 
	$writeme, $throughput, @cmdfiles, $throughput_time, $ftmp, $i );

GetOptions(
	"perf_run_number=i" => \$perf_run_number,
	"scale_factor=i" => \$scale_factor,
	"num_of_streams=i" => \$num_of_streams,
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

if ( $num_of_streams ) { $options{ 'num_of_streams' } = $num_of_streams; }
elsif ( $options{ 'num_of_streams' } ) {
        $scale_factor =  $options{ 'num_of_streams' };
}
else
{
        die "No num_of_streams $!";
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

system("dbmcli -d $SID -u dbm,dbm \"param_getvalue DATE_TIME_FORMAT\" 2>&1 > dbm.out") && die "param_getvalue DATE_TIME_FORMAT failed $_\n";

$ftmp = new FileHandle;
unless ( $ftmp->open( "< dbm.out" ) )
	{ die "open file dbm.out failed $!"; }
# read the first line to find out if there is any errors
my $line1 = <$ftmp>;
$_ = $line1;
if ( /ERR/i )
{
	close($ftmp);
	system("rm", "dbm.out");
	die "param_getval DATETIME_FORMAT failed\n";
}
else 
{
	$line1 = <$ftmp>;
	$_ = $line1;
	if ( /INTERNAL/i )
	{
		close($ftmp);
		system("rm", "dbm.out");
		#print "DATETIME_FORMAT is internal\n";
	}
	else
	{
		close($ftmp);
		system("rm", "dbm.out");

		@cmdfiles = ("$DBT3_INSTALL_PATH/dbdriver/scripts/sapdb/change_datetime_format");
		eval {exe_dbm_cmds("dbm", "dbm", "$SID", "localhost", @cmdfiles)};
		if ( $@ )
		{
			die "error changing datetime format: $@";
		}
	}
}

# get execution time for the throughput test
system ("dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt \"sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF$perf_run_number.THRUPUT'\"|grep -v 'OK' |grep -v 'END' | xargs $DBT3_INSTALL_PATH/dbdriver/scripts/string_to_number.sh>> thruput.out");

unless ( $ftmp->open( "< thruput.out" ) )
	{ die "open file thruput.out failed $!"; }
$_ = <$ftmp>;
chop;
if ( /ERR/i )
{
	close($ftmp);
	system("rm", "thruput.out");
	die "query throughput execution time failed";
}
else
{
	$throughput_time = $_; 
}
close($ftmp);
system("rm", "thruput.out");

$throughput = 22 * 3600 * $num_of_streams * $scale_factor / $throughput_time;
printf "throughput = %.2f\n", $throughput;
