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
use SAP::DBTech::dbm;
use Pod::Usage;
use FileHandle;
use Getopt::Long;
use Env qw(DBT3_INSTALL_PATH SID DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE/Sapdbpms";
use DBM::Exe_dbm_cmds;
use REPM::Exe_repm_cmds;

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
	$dbdriver_sapdb_path, $power, @cmdfiles, @power_query, @power_refresh,
	$ftmp, $i );

GetOptions(
	"perf_run_number=i" => \$perf_run_number,
	"scale_factor=i" => \$scale_factor,
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

$dbdriver_sapdb_path = "$DBT3_INSTALL_PATH/dbdriver/scripts/sapdb";

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

		@cmdfiles = ("$dbdriver_sapdb_path/change_datetime_format");
		eval {exe_dbm_cmds("dbm", "dbm", "$SID", "localhost", @cmdfiles)};
		if ( $@ )
		{
			die "error changing datetime format: $@";
		}
	}
}

# get execution time for the power queries
for ($i=1; $i<=22; $i++)
{
	# using repman interface returns only the status
	# in this case, I need the sql result, maybe DBI can solve this problem
	# for now I just used system cammand
	system ("dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt \"sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF$perf_run_number.POWER.Q$i'\"|grep -v 'OK' |grep -v 'END' | xargs $DBT3_INSTALL_PATH/dbdriver/scripts/string_to_number.sh>> query.out");
}

unless ( $ftmp->open( "< query.out" ) )
	{ die "open file query.out failed $!"; }
$i = 0;
while (<$ftmp>)
{
	chop;
	if ( /ERR/i )
	{
		close($ftmp);
		system("rm", "query.out");
		die "query power query execution time failed";
	}
	else
	{
		$power_query[$i] = $_; 
		$i++;
	}
}
close($ftmp);
system("rm", "query.out");

# get execution time for the power refresh functions
for ($i=1; $i<=2; $i++)
{
	# using repman interface returns only the status
	# in this case, I need the sql result, maybe DBI can solve this problem
	# for now I just used system cammand
	system ("dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt \"sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF$perf_run_number.POWER.RF$i'\"|grep -v 'OK' |grep -v 'END' | xargs $DBT3_INSTALL_PATH/dbdriver/scripts/string_to_number.sh>> refresh.out");
}

unless ( $ftmp->open( "< refresh.out" ) )
	{ die "open file refresh.out failed $!"; }
$i = 0;
while (<$ftmp>)
{
	chop;
	if ( /ERR/i )
	{
		close($ftmp);
		system("rm", "refresh.out");
		die "query power refresh function execution time failed";
	}
	else
	{
		$power_refresh[$i] = $_; 
		$i++;
	}
}
close($ftmp);
system("rm", "refresh.out");

my $tmp_query = 1;
for ( $i=0; $i<22; $i++ )
{
	$tmp_query = $power_query[$i] * $tmp_query;
}
my $tmp_refresh = 1;
for ( $i=0; $i<2; $i++ )
{
	$tmp_refresh = $power_refresh[$i] * $tmp_refresh
}

$power = (3600 * $scale_factor) / ($tmp_query * $tmp_refresh)**(1/24);
printf "power = %.2f\n", $power;
