#!/usr/bin/perl -w 

use strict;
use English;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Getopt::Long;
use CGI qw(:standard *table start_ul :html3);
use Pod::Usage;

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

my ( $indir, $hlp, $outfile, $configfile, $writeme );

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

unless ( $fconfig->open( "< $indir/config.txt" ) )   { die "No config file $!"; }
my (%configs, $num_data, $num_sys, $num_log);

$num_data=0;
$num_sys=0;
$num_log=0;
while (<$fconfig>)
{
	chop $_;
	if (/^DATADEV/) { $num_data++; }
	if (/^SYSDEV/) { $num_sys++; }
	if (/^ARCHIVE/) { $num_log++; }
	my ( $var, $value ) = split /:/, $_;
	$configs{ $var } = $value;
}
$fconfig->close;

print $fh h1("DBT3 Test Result");
print $fh h2("Configurations: ");
#generate configuration table
print $fh table({-border=>undef}, caption('DBT3 Configurations'),
	Tr({-valign=>"TOP"},
	[
		th(["Software Version", "Hardware Configuration", "Run Parameters"]),
		td(["Linux Kernel: $configs{'kernel'}", "$configs{'CPUS'} CPUS @ $configs{'MHz'} MHz", "Database Scale Factor: $configs{'scale_factor'}"]),
		td(["SAP DB: $configs{'sapdb'}", "CPU model $configs{'model'}", "Number of stream for throughput run: $configs{'num_stream'}"]),
		td(["sysstat", "$configs{'memory'} Memory", ""]),
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
	print "calc_composite.out exist\n";
	my $fcomposite = new FileHandle;
	unless ( $fcomposite->open( "< $indir/calc_composite.out" ) )   { die "No composite file $!"; }
	while (<$fcomposite>)
	{
		next if (/^call/ || /^the/);
		chop $_;
		
		#the lines are in the order: power, throughput, composite
		if ($power==0) {$power=$_;}
		elsif ($thuput==0) {$thuput=$_;}
		else {$composite=$_;}
	}
	print "power $power, thuput $thuput, composite $composite\n";
}	
elsif ( -e "$indir/calc_power.out" )
{
	my $fpower = new FileHandle;
	unless ( $fpower->open( "< $indir/calc_power.out" ) )   { die "No power file $!"; }
	while (<$fpower>)
	{
		next if (!/^[0-9]/);
		chop $_;
		$power=$_;
	}
}	
elsif ( -e "$indir/calc_thuput.out" )
{
	my $fthuput = new FileHandle;
	unless ( $fthuput->open( "< $indir/calc_thuput.out" ) )   { die "No thuput file $!"; }
	while (<$fthuput>)
	{
		next if (!/^[0-9]/);
		chop $_;
		$thuput=$_;
	}
}	

print $fh h2("DBT3 Metrics: ");
print $fh start_table({-border=>undef});
print $fh caption('DBT3 Metrics'); 
#if it is a complete dbt3 run
if ($composite != 0 && $power !=0 && $thuput != 0) 
{
	print $fh Tr({-valign=>"TOP"},
	[
		th(["Composite(queries per hour)", "Query Processing Power(queries per hour)", "Throughput Numerical Quantity(queries per hour)"]), 
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
print $fh Tr(th[("Task","Start Time", "End Time", "Elapsed Time")]);
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
			$diffload="$_"." seconds"; 
		}
	}
	$fdbt3->close;
	print $fh Tr(td[("LOAD", $sload, $eload, $diffload)]);
	
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chop $_;
		if (/^'PERF1'/ || /^'PERF1\.POWER'/ || /^'PERF1\.POWER\.RF.'/ 
			|| /^'PERF1\.POWER\.QS'/ || /^'PERF1\.THRUPUT'/ ||
			/^'PERF1\.THRUPUT\.RFST.'/ || /^'PERF1\.THRUPUT\.QS.'/
			|| /^'PERF1\.THRUPUT\.QS.'/)
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /;/, $_;
			print $fh Tr(td[($taskname, $stime, $etime, $difftime)]);
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
			my ( $taskname, $stime, $etime, $difftime ) = split /;/, $_;
			print $fh Tr(td[($taskname, $stime, $etime, $difftime)]);
		}
	}
	$fqtime->close;
}
#if it is a throughput run
elsif ($composite==0 && $power==0 && $thuput!=0)
{
	my $fqtime = new FileHandle;
	unless ( $fqtime->open( "< $indir/q_time.out" ) )   { die "No q_time file $!"; }
	while (<$fqtime>)
	{
		chop $_;
		if ( /^'PERF1\.THRUPUT'/ || /^'PERF1\.THRUPUT\.RFST.'/ || /^'PERF1\.THRUPUT\.QS.'/ )
		{
			my ( $taskname, $stime, $etime, $difftime ) = split /;/, $_;
			print $fh Tr(td[($taskname, $stime, $etime, $difftime)]);
		}
	}
	$fqtime->close;
}
print $fh end_table, "\n";

#generate gnuplot files
#change dbt3.sar.config file
my $fsarcfg = new FileHandle;
unless ( $fsarcfg->open( "< dbt3.sar.config" ) )   { die "No dbt3.sar.config file $!"; }
my $ftmp = new FileHandle;
unless ( $ftmp->open( "> tmp.sar.config" ) )   { die "No tmp.sar.config file $!"; }
while (<$fsarcfg>)
{
	if (!(/^INDIR/ || /^OUTDIR/))
	{
		print $ftmp $_;
	}
	else
	{
		chop $_;
		if (/^INDIR/) { s/=.*/=$indir/g; }
		else {s/=.*\//=$indir\//g;}
		print $ftmp $_, "\n";
	}
}
$fsarcfg->close;
$ftmp->close;
system("mv", "tmp.sar.config", "dbt3.sar.config");

#generate $indir/plot directory
if (! -d "$indir/plot")
{
	unless (mkdir("$indir/plot", 0755)) { die "create plot directory failed $!"; }
}

#generate gnuplot files
system("./dbt3_gen_graphs_2.5.sh", "$indir", "$indir/plot");


#here is where we write the table
print $fh h2("gnuplot files generated from system monitors \(sysstat and procps\)");
table_of_glob("$indir/plot", "*.png");

system("cp", "$indir/io.txt", "$indir/plot/iostat.txt");
system("cp", "$indir/vmstat.out", "$indir/plot/vmstat.txt");
print $fh h2("Raw data generated from system monitors \(sysstat and procps\)");
table_of_glob("$indir/plot", "*.txt");

print $fh h2("Run log data");
my @runlog;
if ($composite != 0) {@runlog=("dbt3.out", "q_time.out", "calc_composite.out","thuput_qs1","thuput_qs2","refresh_stream1","refresh_stream2");} 
elsif ($power != 0) {@runlog=("power.out", "q_time.out", "calc_power.out");} 
elsif ($thuput != 0) {@runlog=("thuput.out", "q_time.out", "calc_thuput.out","thuput_qs1", "thuput_qs2","refresh_stream1","refresh_stream2");} 
print $fh start_ul;
foreach my $name (@runlog)
{
	print $fh li(a( {-href=>"$indir/$name"}, $name)), "\n";
}
print $fh end_ul;

print $fh h2("Other data");
print $fh start_ul;
print $fh li(a( { -href=>"$indir/meminfo0.out"}, "meminfo before run")), "\n";
print $fh li(a( { -href=>"$indir/meminfo1.out"}, "meminfo after run")), "\n";
print $fh end_ul;

#write table of files 
sub table_of_glob {
	my ($indir, $globname) = @_;
	#generate a list of *.png files
	my @filelist = glob("$indir/$globname");
	print "filelist $#filelist", join ( '  ', @filelist );

	print $fh start_table( { -border => undef });
	print $fh Tr(th[("sar", "vmstat", "iostat")]);

	my (@sarlist, @iostatlist, @vmstatlist, $sar_index, $iostat_index, $vmstat_index);
	$sar_index=0;
	$iostat_index=0;
	$vmstat_index=0;
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
	}
		
	my $max_row=$#sarlist;
	if ($max_row < $#vmstatlist) { $max_row=$#vmstatlist; }
	if ($max_row < $#iostatlist) { $max_row=$#iostatlist; }
	
	for ( my $i = 0; $i <= $max_row; $i++ ) 
	{
		if ($i>$#sarlist) {$sarlist[ $i ]="";}
		if ($i>$#vmstatlist) {$vmstatlist[ $i ]="";}
		if ($i>$#iostatlist) {$iostatlist[ $i ]="";}

		my $sarname=basename($sarlist[ $i ]);
		my $vmstatname=basename($vmstatlist[$i]);
		my $iostatname=basename($iostatlist[$i]);
		print $fh Tr(
			td( a( { -href => "$sarlist[$i]" }, "$sarname" ) ),
			td( a( { -href => "$vmstatlist[$i]" }, "$vmstatname") ),
			td( a( { -href => "$iostatlist[$i]" }, "$iostatname") ),
			), "\n";
	}
	print $fh end_table, "\n";
}
