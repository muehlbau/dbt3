#!/usr/bin/perl -w 

use strict;
use English;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

multi_dbt3_stats.pl

=head1 SYNOPSIS

run dbt3 test multiple times

=head1 ARGUMENTS

 -run <number of tests to run>
 -outdirs <the name of the directories to collect data>
 -scale_factor <scale factor of the runs >
 -num_streams <number of streams for throughput runs >
 -config <config filename to read config from> 
 -write <filename to write config to> 

=cut

my ( $runs, $hlp, @outdirs, $scale_factor, $streams, $configfile, $writeme );

GetOptions(
	"runs=i" => \$runs,
	"outdirs=s" => \@outdirs,
	"help"      => \$hlp,
	"scale_factor=i"    => \$scale_factor,
	"num_streams=i"    => \$streams,
	"config=s"    => \$configfile,
	"write=s"   => \$writeme
);


my $fcf = new FileHandle;
my ( $cline, %options );
my ( $iline, $fh );

if ($hlp) { pod2usage(1); }

#read config from config file
if ( $configfile ) {
    unless ( $fcf->open( "< $configfile" ) ) {
        die "Missing config file $!";
    }
    while ( $cline = $fcf->getline ) {
        next if ( $cline =~ /^#/ );
        chomp $cline;
        my ( $var, $value ) = split /=/, $cline;
        $options{ $var } = $value;
	$_=$var;
	if (/outdirs/)
	{
		$#outdirs++;
	}
    }
    $fcf->close;
}

if ( $runs ) { $options{ 'runs' } = $runs; }
elsif ( !$options{ 'runs' } ) {
    die "No number of runs $!";
} 
else
{
	$runs=$options{ 'runs' };
}

if ($runs != ($#outdirs+1)) { die "the number of output directories does not match number of runs";}

for (my $i=0; $i<=$#outdirs; $i++)
{
	if ( $outdirs[$i] )
	{
		$options{"outdirs$i"}= $outdirs[$i];
	}
	elsif ($options{"outdirs$i"}) 
	{
		$outdirs[$i]=$options{"outdirs$i"};
	}
}

if ( $scale_factor ) { $options{ 'scale_factor' } = $scale_factor; }
elsif ( $options{ 'scale_factor' } )
{
	$scale_factor=$options{ 'scale_factor' };
}
else {
    die "No scale_factor $!";
}

if ( $streams ) { $options{ 'streams' } = $streams; }
elsif ( $options{ 'streams' } ) {
	$streams= $options{ 'streams'};
}
else
{
    die "No number of streams $!";
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

print "Will start $runs dbt3 test with $streams streams and scale factor $scale_factor, the output directories are ", join (' ', @outdirs), "\n";

for (my $i=0; $i<$runs; $i++)
{
	system("./dbt3_stats.sh $scale_factor $streams $outdirs[$i] 2>&1 > dbt3.out");
}
