#!/usr/bin/perl -w 
#
# wb_dbt3_report.pl: generate dbt3 result html
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
# March 2003

use strict;
use English;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Getopt::Long;
use CGI qw(:standard *table start_ul :html3);
use Pod::Usage;
use Env qw(DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE";
use Data_report;

use constant DEBUG => 0;

=head1 NAME

wb_dbt3_report.pl

=head1 SYNOPSIS

generates dbt3 result page

=head1 ARGUMENTS

 --indir <result data directory>
 --outfile <filename - defaults to STDOUT >
 --lvm <0|1 - indicates if lvm is used >
 --file <config filename to read from> 
 --write <config filename to write to> 
 --relative_indir <patch prefix to results dir>

=cut

my $DBT3_VERSION = "1.5";

my ( $indir, $hlp, $use_lvm, $outfile, $configfile, $writeme );
my $relative_indir = ".";

GetOptions(
	"file=s"    => \$configfile,
	"help"      => \$hlp,
	"indir=s"   => \$indir,
	"outfile=s" => \$outfile,
	"relative_indir=s" => \$relative_indir,
	"use_lvm=i" => \$use_lvm,
	"write=s"   => \$writeme
);


my $fcf = new FileHandle;
my ( $cline, %options );
my ( $iline, $fh );

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

if ( $indir ) { $options{ 'indir' } = $indir; }
elsif ( $options{ 'indir' } ) {
	$indir =  $options{ 'indir' };
}
else
{
	die "No input dir $!";
}

if ( $use_lvm ) { $options{ 'use_lvm' } = $use_lvm; }
elsif ( $options{ 'use_lvm' } ) {
	$use_lvm =  $options{ 'use_lvm' };
}
else
{
	$use_lvm = 0;
}

if ( $outfile ) {
	$options{ 'outfile' } = $outfile;
	$fh = new FileHandle;
	unless ( $fh->open( "> $outfile" ) ) { die "can't open output file $!"; }
} 
elsif ( $options{ 'outfile' } ) {
	$outfile=$options{ 'outfile' };
	$fh = new FileHandle;
	unless ($fh->open("> $outfile")) { die "can't open output file $!"; }
}
else
{
	$fh = *STDOUT;
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

#read configuration from config.txt file
my $fconfig = new FileHandle;

print "indir is $indir\n";
unless ( $fconfig->open( "< $indir/config.txt" ) )   { die "No config file $!"; }
my (%configs);

while (<$fconfig>)
{
	chomp $_;
	my ( $var, $value ) = split /:/, $_;
	$configs{ $var } = $value;
}
$fconfig->close;

print "indir $indir, relative_dir $relative_indir\n";

print $fh h1("DBT-3 Test Result");
print $fh h2("Configurations: ");
# generate configuration table
print $fh start_table({-border=>undef}), "\n";
print $fh Tr(th(["Software Version", "Hardware Configuration", "Run Parameters"])), "\n";
print $fh Tr(td(["Linux Kernel: $configs{'kernel'}", "$configs{'CPUS'} CPUS @ $configs{'MHz'} MHz", "Database Scale Factor: $configs{'scale_factor'}"])), "\n";
print $fh Tr(td(["PostgreSQL: $configs{'pgsql'}", "CPU model $configs{'model'}", "Number of streams for throughput run: $configs{'num_stream'}"])), "\n";
print $fh Tr(td(["sysstat:  $configs{'sysstat'}", "$configs{'memory'} Memory", "shmmax: $configs{'shmmax'}"])), "\n";
print $fh Tr(td(["distribution: $configs{'distribution'}", "Node: $configs{'node'}", "database parameter: $configs{'db_param'}"])), "\n";
print $fh Tr(td(["procps: $configs{'procps'}", "", "Put pgsql_tmp on different drive: $configs{'redirect_tmp'}"])), "\n";
print $fh Tr(td(["Test Kit Version $DBT3_VERSION", "", "Put WAL on different drive: $configs{'redirect_xlog'}"])), "\n";

if ($use_lvm == 1)
{
	system("/sbin/lvm version &> .lvm.tmp");
	unless ( $fcf->open( "< .lvm.tmp" ) ) {
		 die "Missing config file $!";
	}

	my ($lvm_version, $name);
	while (<$fcf>)
	{
		next if ( ! /LVM version/ );
		chomp;
		($name, $lvm_version) = split /:/;
	}
	$fcf->close;
	system("rm .lvm.tmp");

	system("/sbin/vgdisplay -v > $indir/vg.txt");
	print $fh Tr(td(["LVM Version: $lvm_version", a({-href=>"$relative_indir/vg.txt"}, "Volume Group"), ""])), "\n";
}
print $fh end_table({-border=>undef}), "\n";

my ($composite, $power, $thruput);

$composite=0;
$power=0;
$thruput=0;
#get run results
if ( -e "$indir/calc_composite.out" )
{
	my $fcomposite = new FileHandle;
	unless ( $fcomposite->open( "< $indir/calc_composite.out" ) )   { die "No composite file $!"; }
	while (<$fcomposite>)
	{
		chomp;
		
		my ( $var, $value ) = split /=/;
		if ( /power/ ) { $power = $value; }
		elsif ( /throughput/ ) { $thruput = $value; }
		elsif ( /composite/) { $composite = $value; }
	}
	close($fcomposite);
	print "power $power, thruput $thruput, composite $composite\n";
}	
elsif ( -e "$indir/calc_power.out" )
{
	my $fpower = new FileHandle;
	unless ( $fpower->open( "< $indir/calc_power.out" ) )   { die "No power file $!"; }
	while (<$fpower>)
	{
		chomp;
		my ( $var, $value ) = split /=/;
		$power=$value;
	}
	close($fpower);
}	
elsif ( -e "$indir/calc_thruput.out" )
{
	my $fthruput = new FileHandle;
	unless ( $fthruput->open( "< $indir/calc_thruput.out" ) )   { die "No thruput file $!"; }
	while (<$fthruput>)
	{
		chomp;
		my ( $var, $value ) = split /=/;
		$thruput=$value;
	}
	close($fthruput);
}	

print $fh h2("DBT-3 Metrics: ");
print $fh start_table({-border=>undef});
#if it is a complete dbt3 run
if ($composite != 0 && $power !=0 && $thruput != 0) 
{
	print $fh Tr({-valign=>"TOP"},
	[
		th([a( {-href=>"$relative_indir/dbt3_explain.html#Composite"}, "Composite"), a( {-href=>"$relative_indir/dbt3_explain.html#Power"}, "Query Processing Power"), a( {-href=>"$relative_indir/dbt3_explain.html#Throughput"}, "Throughput Numerical Quantity")]), 
		td(["$composite", "$power", "$thruput"])
	]);
}
#if it is a power run
elsif ($composite==0 && $power!=0 && $thruput==0)
{
	print $fh Tr({-valign=>"TOP"},
	[
		th(["Power"]), 
		td(["$power"])
	]);
}
#if it is a throughput run
elsif ($composite==0 && $power==0 && $thruput!=0)
{
	print $fh Tr({-valign=>"TOP"},
	[
		th(["Throughput"]), 
		td(["$thruput"])
	]);
}
print $fh end_table, "\n";

print $fh h3( "Query Times" );
print $fh "<img src=\"" . $relative_indir . "/q_time.png\"/>\n";

#print start_end time for each query

print $fh br;
print $fh start_table( { -border => undef });
print $fh caption("Task Execution Time");
print $fh Tr(th[(a( {-href=>"$relative_indir/dbt3_explain.html#DBT-3"},"Task"),"Start Time", "End Time", "Elapsed Time")]);
#if it is a complete dbt3 run
if ($composite != 0 && $power !=0 && $thruput != 0) 
{
	#get load time from dbt3.out
	my $fdbt3 = new FileHandle;
	unless ( $fdbt3->open( "< $indir/dbt3.out" ) )   { die "No dbt3.out file $!"; }
	my ($sload, $eload, $diffload);
	while (<$fdbt3>)
	{
		next if (!/load test/);
		chomp $_;
		if (/start/) 
		{
			s/start load test//g;
			$sload=$_; 
		}
		elsif (/end/) 
		{
			s/load test end//g;
			$eload=$_; 
		}
		elsif (/elapsed/) 
		{
			s/[a-z ]*//g;
			$diffload=$_; 
		}
	}
	$fdbt3->close;
	if ( -e "$indir/calc_composite.out" )
	{
		my $fcomposite = new FileHandle;
		unless ( $fcomposite->open( ">> $indir/calc_composite.out" ) ) 
			{ die "No composite file $!"; }
		print $fcomposite "load = $diffload\n";
		close($fcomposite);
	}
		
	#convert load test time from seconds to hh:mm:ss format
	print "diffload $diffload\n";
	my ($h, $m, $s, $tmp_index);
	($h, $m, $s) = convert_time_format($diffload);
	print $fh "<tr><td><a href=\"$relative_indir/dbt3_explain.html#Load\"> LOAD</a></td><td>$sload</td><td>$eload</td>";
	printf $fh "<td>%02d:%02d:%02d</td></tr>", $h, $m, $s;
	
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chomp $_;
		if ( /PERF/ )
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /\|/, $_;
			$taskname=~s/'//g;
			$difftime=~s/'//g;
			$stime=~s/.[0-9]+$//g;
			$etime=~s/.[0-9]+$//g;
			my $pointer;
			if ( $taskname =~ /PERF1( )*$/ || $taskname =~ /PERF1\.POWER( )*$/ || $taskname =~ /PERF1\.POWER\.RF./ || $taskname =~ /PERF1\.POWER\.QS( )*$/ || $taskname =~ /PERF1\.THRUPUT( )*$/ || $taskname =~ /PERF1\.THRUPUT\.RFST[0-9]( )*$/ || $taskname =~ /PERF1\.THRUPUT\.QS.\.ALL/)
			{
				$_=$taskname;
				if (/PERF1( )*$/) {$pointer="$relative_indir/dbt3_explain.html#Performance";}
				elsif (/PERF1\.POWER( )*$/) {$pointer="$relative_indir/dbt3_explain.html#Power_Test";}
				elsif (/PERF1\.POWER\.QS( )*$/) {$pointer="$relative_indir/dbt3_explain.html#Query_Stream";}
				elsif (/PERF1\.THRUPUT( )*$/) {$pointer="$relative_indir/dbt3_explain.html#Throughput_Test";}
				elsif (/ALL/) {$pointer="$relative_indir/dbt3_explain.html#Query_Stream";}
				elsif (/PERF1\..*\.RFST/) {$pointer="$relative_indir/dbt3_explain.html#Refresh_Stream";}
				elsif (/PERF1\..*\.RF1/) {$pointer="$relative_indir/dbt3_explain.html#Refresh_Function_1";}
				elsif (/PERF1\..*\.RF2/) {$pointer="$relative_indir/dbt3_explain.html#Refresh_Function_2";}
				print $fh Tr(td[(a( {-href=>"$pointer"}, "$taskname"), $stime, $etime, $difftime)]);
			}
		}
	}
	$fqtime->close;
}
#if it is a power run
elsif ($composite==0 && $power!=0 && $thruput==0)
{
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chomp $_;
		if (/PERF1\.POWER/ || /PERF1\.POWER\.RF./ ||  
			/PERF1\.POWER\.QS/)
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /\|/, $_;
			$taskname=~s/'//g;
			$difftime=~s/'//g;
			$stime=~s/.[0-9]+$//g;
			$etime=~s/.[0-9]+$//g;
			print $fh Tr(td[($taskname, $stime, $etime, $difftime)]);
		}
	}
	$fqtime->close;
}
#if it is a throughput run or others
#elsif ($composite==0 && $power==0 && $thruput!=0)
else
{
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chomp $_;
		if ( /PERF1\.THRUPUT/ || /PERF1\.THRUPUT\.RFST./ || /PERF1\.THRUPUT\.QS./ )
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /\|/, $_;
			$taskname=~s/'//g;
			$difftime=~s/'//g;
			$stime=~s/.[0-9]+$//g;
			$etime=~s/.[0-9]+$//g;
			print $fh Tr(td[($taskname, $stime, $etime, $difftime)]);
		}
	}
	$fqtime->close;
}
print $fh end_table, "\n";

#generate $indir/plot directory
if ( ! -d "$indir/plot" ) {
	unless ( mkdir( "$indir/plot", 0755 ) ) {
		die "create plot directory failed $!";
	}
}

system( "( cd $indir/plot; ln -s ../iostat/load.iostat.out load.iostat.txt)" );
system( "( cd $indir/plot; ln -s ../iostat/load.iostatx.out load.iostatx.txt)" );
system( "( cd $indir/plot; ln -s ../vmstat/load.vmstat.out load.vmstat.txt)" );
system( "( cd $indir/plot; sar -f ../sar/load.sar.out -A > load.sar.txt)" );
system( "( cd $indir/plot; ln -s ../prof/Load_Test.prof load_prof.txt)" );

system( "( cd $indir/plot; ln -s ../iostat/power1.iostat.out power.iostat.txt)" );
system( "( cd $indir/plot; ln -s ../iostat/power1.iostatx.out power.iostatx.txt)" );
system( "( cd $indir/plot; ln -s ../vmstat/power1.vmstat.out power.vmstat.txt)" );
system( "( cd $indir/plot; sar -f ../sar/power1.sar.out -A > power.sar.txt)" );
system( "( cd $indir/plot; ln -s ../prof/Power_Test_1.prof power1_prof.txt)" );

system( "( cd $indir/plot; ln -s ../iostat/throughput1.iostat.out thruput.iostat.txt)" );
system( "( cd $indir/plot; ln -s ../iostat/throughput1.iostatx.out thruput.iostatx.txt)" );
system( "( cd $indir/plot; ln -s ../vmstat/throughput1.vmstat.out thruput.vmstat.txt)" );
system( "( cd $indir/plot; sar -f ../sar/throughput1.sar.out -A > thruput.sar.txt)" );
system( "( cd $indir/plot; ln -s ../prof/Throughput_Test_1.prof thruput1_prof.txt)" );

print $fh h2("Raw data");
table_of_glob("$indir/plot", "$relative_indir/plot", "*.txt", 0);

print $fh h2("gnuplot charts");

table_of_glob("$indir/plot", "$relative_indir/plot", "*.png", 0);

print $fh h2("Run log data");
my @runlog;
my @runlog2;

# if it is a power run
if ($power != 0 && $composite == 0 && $thruput==0) {@runlog=("power.out", "q_time.out", "calc_power.out");} 
else {
	if ($composite != 0) {
		@runlog = ( "dbt3.out", "q_time.out" );
	} elsif ($thruput != 0) {
		@runlog = ( "thruput.out", "q_time.out" );
	} else {
		@runlog=("q_time.out");
	}

	my ( $num_stream );
	$num_stream = $configs{'num_stream'};

	print $fh h2("Power and Throughput Test Query Results");
	push @runlog2, "power_query.result";
	push @runlog2, "power.perf1.rf1.result";
	push @runlog2, "power.perf1.rf2.result";
	for ( my $i = 1; $i <= $num_stream; $i++ ) {
		push @runlog2, "thruput_qs$i.result";
		push @runlog2, "thruput.perf1.stream$i.rf1.result";
		push @runlog2, "thruput.perf1.stream$i.rf2.result";
	}
}
	
print $fh start_ul;
foreach my $name ( @runlog ) {
	print $fh li( a( { -href => "$relative_indir/$name" }, $name ) ), "\n";
}
foreach my $name ( @runlog2 ) {
	print $fh li( a( { -href => "$relative_indir/run/$name" }, $name ) ),
		"\n";
}
print $fh end_ul;

print $fh h2("Database Monitor Data");
print $fh start_ul;
system("mkdir $indir/param; mv $indir/*param* $indir/param");
system("mkdir $indir/indexes; mv $indir/*indexes* $indir/indexes");
print $fh li(a( { -href=>"$relative_indir/param"}, "database parameters")), "\n";
print $fh li(a( { -href=>"$relative_indir/indexes"}, "database indexes and primary keys")), "\n";
print $fh li(a( { -href=>"$relative_indir/db_stat"}, "database monitor files")), "\n";
print $fh li(a( { -href=>"$relative_indir/db_logfile.txt"}, "database log files")), "\n";
#print $fh li(a( { -href=>"$relative_indir/pg_stats.tar.gz"}, "pg statisitcs")), "\n";
print $fh end_ul;

print $fh h2("Other data");
print $fh start_ul;
#print $fh li(a( { -href=>"$relative_indir/meminfo0.out"}, "meminfo before run")), "\n";
#print $fh li(a( { -href=>"$relative_indir/meminfo1.out"}, "meminfo after run")), "\n";
print $fh li(a( { -href=>"$relative_indir/ipcs/"}, "ipcs data")), "\n";
print $fh end_ul;

# write table of files 
sub table_of_glob {
	my ( $indir, $relative_indir, $globname, $flag ) = @_;

	#generate a list of *.png files
	my @filelist = glob( "$indir/$globname" );
	print "filelist $#filelist", join ( '  ', @filelist ) if DEBUG;

	print $fh start_table( { -border => undef } );
	if ( $flag == 0 ) {
		print $fh Tr( th[ ( "sar", "vmstat", "iostat",
			"readprofile" ) ] );
	} else {
		print $fh Tr( th[ ( "sar", "vmstat", "iostat" ) ] );
	}

	my ( @sarlist, @iostatlist, @vmstatlist, @profilelist, $sar_index,
		$iostat_index, $vmstat_index, $profile_index );
	$sar_index=0;
	$iostat_index=0;
	$vmstat_index=0;
	$profile_index=0;
	for ( my $i = 0; $i <= $#filelist; $i++ ) {
		$_=$filelist[$i];
		if ( /sar/ ) {
			$sarlist[$sar_index]=$_;
			$sar_index++;
		} elsif ( /vmstat/ ) {
			$vmstatlist[$vmstat_index]=$_;
			$vmstat_index++;
		} elsif ( /iostat/ ) {
			$iostatlist[$iostat_index]=$_;
			$iostat_index++;
		} elsif (/prof/) {
			$profilelist[$profile_index]=$_;
			$profile_index++;
		}
	}
		
	my $max_row = $#sarlist;
	if ( $max_row < $#vmstatlist ) { $max_row = $#vmstatlist; }
	if ( $max_row < $#iostatlist ) { $max_row = $#iostatlist; }
	if ( $max_row < $#profilelist ) { $max_row=$#profilelist; }
	
	my ( $sarname, $vmstatname, $iostatname, $profilename);
	for ( my $i = 0; $i <= $max_row; $i++ ) {
		if ( $i>$#sarlist ) { $sarlist[ $i ]=""; }
		if ( $i>$#vmstatlist ) { $vmstatlist[ $i ]=""; }
		if ( $i>$#iostatlist ) { $iostatlist[ $i ]=""; }
		if ( $i>$#profilelist ) { $profilelist[ $i ]=""; }

		$sarname = basename( $sarlist[ $i ] );
		$vmstatname = basename( $vmstatlist[ $i ]);
		$iostatname = basename( $iostatlist[ $i ]);
		$profilename = basename( $profilelist[ $i ] );
		print $fh Tr(
                       	td( a( { -href => "$relative_indir/$sarname" }, "$sarname" ) ),
                       	td( a( { -href => "$relative_indir/$vmstatname" }, "$vmstatname") ),
       			td( a( { -href => "$relative_indir/$iostatname" }, "$iostatname") ),
       			td( a( { -href => "$relative_indir/$profilename" }, "$profilename") ),
			), "\n";
	}
	print $fh end_table, "\n";
}

sub change_file_name {
	my ($indir, $globname, $from, $to) = @_;
	#generate a list of *.png files
	my @filelist = glob("$indir/$globname");
	print "filelist $#filelist", join ( '  ', @filelist ) if DEBUG;

	for (my $i=0; $i<=$#filelist; $i++)
	{
		my $new_name=$filelist[$i];
		$new_name=~s/$from$/$to/;
		system("mv", "$filelist[$i]", "$new_name");
	}
}
