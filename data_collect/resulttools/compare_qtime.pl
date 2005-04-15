#!/usr/bin/perl -w 

# CVS Strings 
>>>>>>>>>>>>>>>>>>>> File 1
# $Id: compare_qtime.pl 1310 2005-04-15 19:51:07Z fimath $ $Author: fimath $ $Date
>>>>>>>>>>>>>>>>>>>> File 2
# $Id: compare_qtime.pl 1310 2005-04-15 19:51:07Z fimath $ $Author: fimath $ $Date
<<<<<<<<<<<<<<<<<<<<

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use FileHandle;
use CGI qw(:standard :html3);
use Pod::Usage;
use Env qw(DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE";
use Data_report;
use constant DEBUG => 0;

=head1 NAME

compare_qtime.pl

=head1 SYNOPSIS

compare  query execution time between q_time.out in two runs

=head1 ARGUMENTS

 -firstindir <result data directory1>
 -secondindir <result data directory2>
 -outfile <filename - defaults to STDOUT >
 -file <config filename to read from> 
 -write <config filename to write to> 

=cut

my ( $indir1, $indir2, $hlp, $outfile, $configfile, $writeme );

GetOptions(
	"firstindir=s" => \$indir1,
	"secondindir=s" => \$indir2,
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

if ( $indir1 ) { $options{ 'firstindir' } = $indir1; }
elsif ( $options{ 'firstindir' } ) {
	$indir1 =  $options{ 'firstindir' };
}
else
{
	die "No input dir1 $!";
}

if ( $indir2 ) { $options{ 'secondindir' } = $indir2; }
elsif ( $options{ 'secondindir' } ) {
	$indir2 =  $options{ 'secondindir' };
}
else
{
	die "No input dir2 $!";
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

my ( $fqtime1, $fqtime2 );
$fqtime1 = new FileHandle;
$fqtime2 = new FileHandle;
unless ( $fqtime1->open( "< $indir1/q_time.out" ) )   { die "No q_time.out file in $indir1 $!"; }
unless ( $fqtime2->open( "< $indir2/q_time.out" ) )   { die "No q_time.out file in $indir2 $!"; }

print $fh "file1: $indir1\n";
print $fh "file2: $indir2\n";
print $fh "task name			exe_time1	exe_time2	diff_time\n";
while (<$fqtime1>)
{
	# skip the first two lines
	next if ( /^  / || /^--/ || /\(/ || /^$/ );
	# print "q_time1: $_\n";
	chop;
	my ($task_name1, $start_time1, $end_time1, $diff_time1) = split /\|/;

	seek($fqtime2, 0, 0); 
	while (<$fqtime2>) 
	{
		next if ( /^  / || /^--/ || /\(/ || (! /$task_name1/ ) );
		chop;
		# found the matching line
		# print "q_time2: $_\n";
		my ($task_name2, $start_time2, $end_time2, $diff_time2) = split /\|/;
		my ($time_in_sec1, $time_in_sec2, $diff_time);
		$time_in_sec1 =  convert_to_seconds($diff_time1);
		$time_in_sec2 =  convert_to_seconds($diff_time2);
		$diff_time = $time_in_sec1 - $time_in_sec2;
		print $fh "$task_name1 $diff_time1	$diff_time2	$diff_time\n";
		last;
	}
}
