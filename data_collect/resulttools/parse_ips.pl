#!/usr/bin/perl -w 

# CVS Strings
# $Author: fimath $ $Date: 2005-03-04 09:10:26 -0800 (Fri, 04 Mar 2005) $ $Id: parse_ips.pl 1213 2005-03-04 17:10:26Z fimath $

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use FileHandle;
use CGI qw(:standard :html3);
use Pod::Usage;

use constant DEBUG => 0;

# Thanks, bryce!

=head1 NAME 

parse_ips.pl

=head1 SYNOPSIS

munges data from csv file produced by dbt kits
Creates a gnuplot data file as output

=cut

# START HERE BUBBA

=head1 ARGUMENTS

  -file <config file> - All config file options can be overwritten by command line
  -infile <filename> - A text file contain vmstat output
  -outfile <filename prefix> - program will create .dat and .csv files
  -comment <string> - text for first line of output files
  -write <filename> - write a configuration file for repeated runs

=cut

my ( $infile, $outfile, $comment, $configfile, $writeme, $hlp );

my ( @ipsl, %options, $cline, $line, );

GetOptions(
            "infile=s"  => \$infile,
            "outfile=s" => \$outfile,
            "comment=s" => \$comment,
            "help"      => \$hlp,
            "write=s"   => \$writeme,
            "file=s"    => \$configfile
);

my $fin  = new FileHandle;
my $fdat = new FileHandle;
my $fcf  = new FileHandle;

if ( $hlp ) { pod2usage( 1 ); }

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

if ( $infile ) { $options{ 'infile' } = $infile; }
elsif ( !$options{ 'infile' } ) {
    die "No input file $!";
}

if ( $outfile ) { $options{ 'outfile' } = $outfile; }
elsif ( !$options{ 'outfile' } ) {
    die "No output file $!";
}

if ( $comment ) { $options{ 'comment' } = $comment; }
elsif ( !$options{ 'comment' } ) {
    $options{ 'comment' } = "Transaction data";
}

my $cnt = 1;

unless ( $fin->open( "$options{ 'infile' }" ) ) { die "can't open file $!"; }
unless ( $fdat->open( "> $options{'outfile'}.dat" ) ) { die "can't open file $!"; }
print $fdat "# $options{'comment'} \n";
while ( $line = $fin->getline ) {
    chomp $line;
    my @ipsl = split /,/, $line;
    print $fdat "$cnt  $ipsl[1]\n";
    $cnt++;
}
$fin->close;
$fdat->close;

if ( $writeme ) {
    my $ncf = new FileHandle;
    unless ( $ncf->open( "> $writeme" ) ) { die "can't open file $!"; }
    my $name;
    foreach $name ( keys( %options ) ) {
        print $ncf $name, "=", $options{ $name }, "\n";
    }
    $ncf->close;
}
