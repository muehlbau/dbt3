#!/usr/bin/perl -w 
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
use Env qw(DBT3_INSTALL_PATH SID DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE";
use Data_report;

use constant DEBUG => 0;

=head1 NAME

wb_dbt3_report.pl

=head1 SYNOPSIS

generates dbt3 result page

=head1 ARGUMENTS

 -indir <result data directory>
 -outfile <filename - defaults to STDOUT >
 -file <config filename to read from> 
 -write <config filename to write to> 

=cut

my ( $indir, $hlp, $outfile, $configfile, $writeme, $relative_indir );

GetOptions(
	"indir=s" => \$indir,
	"outfile=s" => \$outfile,
	"help"      => \$hlp,
	"file=s"    => \$configfile,
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
	chop $_;
	my ( $var, $value ) = split /:/, $_;
	$configs{ $var } = $value;
}
$fconfig->close;

# get relative input dir
if ($indir =~ /(\w+)$/)
{
        $relative_indir = "./".$1;
}

print $fh h1("DBT-3 Test Result");
print $fh h2("Configurations: ");
#generate configuration table
print $fh table({-border=>undef},
	Tr({-valign=>"TOP"},
	[
		th(["Software Version", "Hardware Configuration", "Run Parameters"]),
		td(["Linux Kernel: $configs{'kernel'}", "$configs{'CPUS'} CPUS @ $configs{'MHz'} MHz", "Database Scale Factor: $configs{'scale_factor'}"]),
		td(["SAP DB: $configs{'sapdb'}", "CPU model $configs{'model'}", "Number of streams for throughput run: $configs{'num_stream'}"]),
		td(["sysstat:  $configs{'sysstat'}", "$configs{'memory'} Memory", "shmmax: $configs{'shmmax'}"]),
		td(["procps: $configs{'procps'}", "$configs{'data_dev_space'}", ""]),
		td(["Test Kit Version 1.0", "$configs{'sys_dev_space'}", ""]),
		td(["", "$configs{'log_dev_space'}", ""])
	])), "\n";

my ($composite, $power, $thuput);

$composite=0;
$power=0;
$thuput=0;
#get run results
if ( -e "$indir/calc_composite.out" )
{
	my $fcomposite = new FileHandle;
	unless ( $fcomposite->open( "< $indir/calc_composite.out" ) )   { die "No composite file $!"; }
	while (<$fcomposite>)
	{
		chop;
		
		my ( $var, $value ) = split /=/;
		if ( /power/ ) { $power = $value; }
		elsif ( /throughput/ ) { $thuput = $value; }
		elsif ( /composite/) { $composite = $value; }
	}
	close($fcomposite);
	print "power $power, thuput $thuput, composite $composite\n";
}	
elsif ( -e "$indir/calc_power.out" )
{
	my $fpower = new FileHandle;
	unless ( $fpower->open( "< $indir/calc_power.out" ) )   { die "No power file $!"; }
	while (<$fpower>)
	{
		chop;
		my ( $var, $value ) = split /=/;
		$power=$value;
	}
	close($fpower);
}	
elsif ( -e "$indir/calc_thuput.out" )
{
	my $fthuput = new FileHandle;
	unless ( $fthuput->open( "< $indir/calc_thuput.out" ) )   { die "No thuput file $!"; }
	while (<$fthuput>)
	{
		chop;
		my ( $var, $value ) = split /=/;
		$thuput=$value;
	}
	close($fthuput);
}	

print $fh h2("DBT-3 Metrics: ");
print $fh start_table({-border=>undef});
#print $fh caption('DBT-3 Metrics'); 
#if it is a complete dbt3 run
if ($composite != 0 && $power !=0 && $thuput != 0) 
{
	print $fh Tr({-valign=>"TOP"},
	[
		th([a( {-href=>"$relative_indir/dbt3_explain.html#Composite"}, "Composite"), a( {-href=>"$relative_indir/dbt3_explain.html#Power"}, "Query Processing Power"), a( {-href=>"$relative_indir/dbt3_explain.html#Throughput"}, "Throughput Numerical Quantity")]), 
		td(["$composite", "$power", "$thuput"])
	]);
}
#if it is a power run
elsif ($composite==0 && $power!=0 && $thuput==0)
{
	print $fh Tr({-valign=>"TOP"},
	[
		th(["Power"]), 
		td(["$power"])
	]);
}
#if it is a throughput run
elsif ($composite==0 && $power==0 && $thuput!=0)
{
	print $fh Tr({-valign=>"TOP"},
	[
		th(["Throughput"]), 
		td(["$thuput"])
	]);
}
print $fh end_table, "\n";
#print start_end time for each query

print $fh br;
print $fh start_table( { -border => undef });
print $fh caption("Task Execution Time");
print $fh Tr(th[(a( {-href=>"$relative_indir/dbt3_explain.html#DBT-3"},"Task"),"Start Time", "End Time", "Elapsed Time")]);
#if it is a complete dbt3 run
if ($composite != 0 && $power !=0 && $thuput != 0) 
{
	#get load time from dbt3.out
	my $fdbt3 = new FileHandle;
	unless ( $fdbt3->open( "< $indir/dbt3.out" ) )   { die "No dbt3.out file $!"; }
	my ($sload, $eload, $diffload);
	while (<$fdbt3>)
	{
		next if (!/load test/);
		chop $_;
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
#	print $fh Tr(td[("LOAD", $sload, $eload, "$h:$m:$s")]);
	print $fh "<tr><td><a href=\"$relative_indir/dbt3_explain.html#Load\"> LOAD</a></td><td>$sload</td><td>$eload</td>";
	printf $fh "<td>%02d:%02d:%02d</td></tr>", $h, $m, $s;
	
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chop $_;
		if (/^'PERF1'/ || /^'PERF1\.POWER'/ || /^'PERF1\.POWER\.RF.'/ 
			|| /^'PERF1\.POWER\.QS'/ || /^'PERF1\.THRUPUT'/ ||
			/^'PERF1\.THRUPUT\.RFST.'/ || /^'PERF1\.THRUPUT\.QS.'/
			)
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /';'/, $_;
			$taskname=~s/'//g;
			$difftime=~s/'//g;
			$stime=~s/.[0-9]+$//g;
			$etime=~s/.[0-9]+$//g;
			my $pointer;
			$_=$taskname;
			if (/PERF1$/) {$pointer="$relative_indir/dbt3_explain.html#Performance";}
			elsif (/PERF1\.POWER$/) {$pointer="$relative_indir/dbt3_explain.html#Power_Test";}
			elsif (/PERF1\.THRUPUT$/) {$pointer="$relative_indir/dbt3_explain.html#Throughput_Test";}
			elsif (/PERF1\..*.QS/) {$pointer="$relative_indir/dbt3_explain.html#Query_Stream";}
			elsif (/PERF1\..*\.RFST/) {$pointer="$relative_indir/dbt3_explain.html#Refresh_Stream";}
			elsif (/PERF1\..*\.RF1/) {$pointer="$relative_indir/dbt3_explain.html#Refresh_Function_1";}
			elsif (/PERF1\..*\.RF2/) {$pointer="$relative_indir/dbt3_explain.html#Refresh_Function_2";}
			print $fh Tr(td[(a( {-href=>"$pointer"}, "$taskname"), $stime, $etime, $difftime)]);
		}
	}
	$fqtime->close;
}
#if it is a power run
elsif ($composite==0 && $power!=0 && $thuput==0)
{
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chop $_;
		if (/^'PERF1\.POWER'/ || /^'PERF1\.POWER\.RF.'/ ||  
			/^'PERF1\.POWER\.QS/)
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /';'/, $_;
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
#elsif ($composite==0 && $power==0 && $thuput!=0)
else
{
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chop $_;
		if ( /^'PERF1\.THRUPUT'/ || /^'PERF1\.THRUPUT\.RFST.'/ || /^'PERF1\.THRUPUT\.QS.'/ )
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /';'/, $_;
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
if (! -d "$indir/plot")
{
	unless (mkdir("$indir/plot", 0755)) { die "create plot directory failed $!"; }
}

#generate gnuplot files
system("./dbt3_gen_graphs.sh", "$indir", "$indir/plot");

system("cp", "$indir/iostat.txt", "$indir/plot/iostat.txt");
system("cp", "$indir/vmstat.out", "$indir/plot/vmstat.txt");
system("mv", "$indir/load_prof.txt", "$indir/plot/load_prof.txt");
system("mv", "$indir/power1_prof.txt", "$indir/plot/power1_prof.txt");
system("mv", "$indir/throughput1_prof.txt", "$indir/plot/throughput1_prof.txt");
change_file_name("$indir/plot", "xcons*.dat", ".dat", ".txt");
print $fh h2("Raw data");
table_of_glob("$indir/plot", "$relative_indir/plot", "*.txt", 0);

print $fh h2("gnuplot charts");
print $fh "<form method=\"post\" 
	action=\"http://webdev/jenny/cgi-bin/showchart.cgi \"
        enctype=\"application/x-www-form-urlencoded\">";
print $fh "<INPUT TYPE=\"hidden\" NAME=\"pathname\" VALUE=\"$relative_indir/plot\">";
table_of_glob("$indir/plot", "$relative_indir/plot", "*.png", 1);
print $fh "<INPUT TYPE=\"submit\" NAME=\"showchart\" VALUE=\"Show Charts\">";
print $fh "</form>";

print $fh h2("Run log data");
my @runlog;

#if it is a power run
if ($power != 0 && $composite == 0 && $thuput==0) {@runlog=("power.out", "q_time.out", "calc_power.out");} 
else 
{
	if ($composite != 0) 
	{
		@runlog=("dbt3.out", "q_time.out", "calc_composite.out");
	}
	elsif ($thuput != 0) 
	{
		@runlog=("thuput.out", "q_time.out", "calc_thuput.out");
	} 
	else {@runlog=("q_time.out");}

	my ($num_stream, $log_index);
	$num_stream = $configs{'num_stream'};
	$log_index = $#runlog+1;
	for ( my $i=1; $i<=$num_stream; $i++, $log_index++)
	{
		$runlog[$log_index] = "thuput_qs$i";
	}
	for ( my $i=1; $i<=$num_stream; $i++, $log_index++)
	{
		$runlog[$log_index] = "refresh_stream$i";
	}
}
	
print $fh start_ul;
foreach my $name (@runlog)
{
	print $fh li(a( {-href=>"$relative_indir/$name"}, $name)), "\n";
}
print $fh end_ul;

print $fh h2("Database Monitor Data");
print $fh start_ul;
if (!-e "$indir/db_stat.tar.gz")
{
	system("tar cvfz $indir/db_stat.tar.gz -C $indir db_stat");
	system("rm -rf $indir/db_stat");
}
print $fh li(a( { -href=>"$relative_indir/param.out"}, "database parameters")), "\n";
print $fh li(a( { -href=>"$relative_indir/primary_keys.out"}, "database primary keys")), "\n";
print $fh li(a( { -href=>"$relative_indir/all_ind_columns.out"}, "database indexes")), "\n";
print $fh li(a( { -href=>"$relative_indir/db_stat.tar.gz"}, "database monitor files")), "\n";
my $knldiag=`find /opt/sapdb -name knldiag | head -1`;
chop($knldiag);
if ( -f "$knldiag" )
{
	system("cp $knldiag $indir")
		&& die "Can not copy $knldiag to $indir";
	print $fh li(a( { -href=>"$relative_indir/knldiag"}, "database kernel log file")), "\n";
}
print $fh end_ul;

print $fh h2("Other data");
print $fh start_ul;
print $fh li(a( { -href=>"$relative_indir/meminfo0.out"}, "meminfo before run")), "\n";
print $fh li(a( { -href=>"$relative_indir/meminfo1.out"}, "meminfo after run")), "\n";
if (!-e "$indir/ipcs.tar.gz")
{
	system("tar cvfz $indir/ipcs.tar.gz -C $indir ipcs");
	system("rm -rf $indir/ipcs");
}
print $fh li(a( { -href=>"$relative_indir/ipcs.tar.gz"}, "ipcs data")), "\n";
print $fh end_ul;

#write table of files 
sub table_of_glob {
	my ($indir, $relative_indir, $globname, $flag) = @_;

	#generate a list of *.png files
	my @filelist = glob("$indir/$globname");
	print "filelist $#filelist", join ( '  ', @filelist ) if DEBUG;

	print $fh start_table( { -border => undef });
	if ( $flag == 0 )
	{
		print $fh Tr(th[("sar", "vmstat", "iostat", "xcons", "read_profile")]);
	}
	else
	{
		print $fh Tr(th[("sar", "vmstat", "iostat", "xcons")]);
	}

	my (@sarlist, @iostatlist, @vmstatlist, @xconslist, @profilelist, $sar_index, $iostat_index, $vmstat_index, $xcons_index, $profile_index);
	$sar_index=0;
	$iostat_index=0;
	$vmstat_index=0;
	$xcons_index=0;
	$profile_index=0;
	for ( my $i = 0; $i <= $#filelist; $i++ ) {
		$_=$filelist[$i];
		if (/sar/)
		{
			$sarlist[$sar_index]=$_;
			$sar_index++;
		}
		elsif (/vmstat/)
		{
			$vmstatlist[$vmstat_index]=$_;
			$vmstat_index++;
		}
		elsif (/iostat/)
		{
			$iostatlist[$iostat_index]=$_;
			$iostat_index++;
		}
		elsif (/xcons/)
		{
			$xconslist[$xcons_index]=$_;
			$xcons_index++;
		}
		elsif (/prof/)
		{
			$profilelist[$profile_index]=$_;
			$profile_index++;
		}
	}
		
	my $max_row=$#sarlist;
	if ($max_row < $#vmstatlist) { $max_row=$#vmstatlist; }
	if ($max_row < $#iostatlist) { $max_row=$#iostatlist; }
	if ($max_row < $#xconslist) { $max_row=$#xconslist; }
	if ($max_row < $#profilelist) { $max_row=$#profilelist; }
	
	for ( my $i = 0; $i <= $max_row; $i++ ) 
	{
		if ($i>$#sarlist) {$sarlist[ $i ]="";}
		if ($i>$#vmstatlist) {$vmstatlist[ $i ]="";}
		if ($i>$#iostatlist) {$iostatlist[ $i ]="";}
		if ($i>$#xconslist) {$xconslist[ $i ]="";}

		my $sarname=basename($sarlist[ $i ]);
		my $vmstatname=basename($vmstatlist[$i]);
		my $iostatname=basename($iostatlist[$i]);
		my $xconsname=basename($xconslist[$i]);
		my $profilename=basename($profilelist[$i]);
		if ($flag == 1)
		{
		print $fh Tr(
			td("<INPUT TYPE=\"checkbox\" NAME=\"png\" VALUE=\"$sarname\"> <a href=\"$relative_indir/$sarname\"> $sarname</a>"),
			td("<INPUT TYPE=\"checkbox\" NAME=\"png\" VALUE=\"$vmstatname\"> <a href=\"$relative_indir/$vmstatname\"> $vmstatname</a>"),
			td("<INPUT TYPE=\"checkbox\" NAME=\"png\" VALUE=\"$iostatname\"> <a href=\"$relative_indir/$iostatname\"> $iostatname</a>"),
			td("<INPUT TYPE=\"checkbox\" NAME=\"png\" VALUE=\"$xconsname\"> <a href=\"$relative_indir/$xconsname\"> $xconsname</a>"),
			), "\n";
		}
		else
		{
		print $fh Tr(
                        td( a( { -href => "$relative_indir/$sarname" }, "$sarname" ) ),
                        td( a( { -href => "$relative_indir/$vmstatname" }, "$vmstatname") ),
       			td( a( { -href => "$relative_indir/$iostatname" }, "$iostatname") ),
       			td( a( { -href => "$relative_indir/$xconsname" }, "$xconsname") ),
       			td( a( { -href => "$relative_indir/$profilename" }, "$profilename") ),
			), "\n";
		}
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

