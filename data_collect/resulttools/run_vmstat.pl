#!/usr/bin/perl -w 

use strict;
use English;
use Getopt::Long;
use FileHandle;
use Pod::Usage;

=head1 NAME

run_vmstat.pl

=cut

=head1 SYNOPSIS

run_vmstat.pl -outfile <filename> -interval <int> -count <int> [ -title <title> -keys -version <version> ]

Runs vmstat taking <count> samples at <interval> times.

  Output: ( filename defaults to /tmp/vmstat )
   <filename>.txt - all output 
   <filename>.csv - all output in .csv format
   <filename>.dat - all output in gnuplot input format

=cut

=head1 ARGUMENTS
  -outfile <base filename>
  -interval <integer>
  -count <integer>
  -title <data file header>
  -keys - use human readable headers translated from keyfile
  -version - give name of key file


=cut

sub get_vmstat_v {
    my $str = `vmstat -V 2>&1 `;
    chomp $str;
    my @outline = split / /, $str;
    return $outline[ 2 ];
}

sub get_hr_heads {
    my $keyfile = shift;
    my ( $line, @ostr );
    my $fkey = new FileHandle;
    unless ( $fkey->open( "< $keyfile" ) ) { return 1; }
    while ( ( $line = $fkey->getline ) =~ /^#/ ) {
        my $junk = $line;
    }
    chomp $line;
    @ostr = split /;/, $line;
    $fkey->close;
    return @ostr;
}

my (
     $hlp,    $line,    @spline,   @hrheads, $hrhead, $version,
     $linecc, $outfile, $interval, $count,   $title
);

GetOptions(
            "outfile=s"  => \$outfile,
            "interval=i" => \$interval,
            "help"       => \$hlp,
            "keys"     => \$hrhead,
	    "title=s" => \$title,
            "version=s"    => \$version,
            "count=i"    => \$count
);

if     ( $hlp )     { pod2usage( 1 ); }
unless ( $outfile ) {
    $outfile = "/tmp/vmstat";
    print STDERR "Output defaulting to /tmp/vmstat.*\n";
}
unless ( $interval ) { die "No interval $!"; }
unless ( $count )    { die "No count $!"; }
unless ( $title )    {
    $title = "Vmstat data - Sampled at $interval second intervals";
}
if ( $hrhead ) {
    unless ( $version ) { $version = get_vmstat_v; }
    @hrheads = get_hr_heads( "vmstat.$version.key" );
    if ( $hrheads[ 0 ] eq "1" ) { undef $hrhead; }
}

my $app  = new FileHandle;
my $fdat = new FileHandle;
my $ftxt = new FileHandle;
my $fcsv = new FileHandle;

unless ( $ftxt->open( "> $outfile.txt" ) ) { die "cannot open output $!"; }
unless ( $fdat->open( "> $outfile.dat" ) ) { die "cannot open output $!"; }
unless ( $fcsv->open( "> $outfile.csv" ) ) { die "cannot open output $!"; }
unless ( $app->open( "vmstat -n $interval $count | " ) ) {
    die "cannot open output $!";
}

print $fdat "# $title \n";
print $fcsv "$title \n";
print $ftxt "$title \n";

# Write the first line to the txt file only
#
$line = $app->getline;
print $ftxt $line;

#parse the headers

$line = $app->getline;
print $ftxt $line;
if ( $hrhead ) {
    print $fcsv join ( ',', @hrheads ), "\n";
    print $fdat "# ", join ( ' ', @hrheads ), "\n";
} else {
    chomp $line;
    $line =~ s/^\s+//;
    @spline = split /\s+/, $line;
    print $fcsv join ( ',', @spline ), "\n";
    print $fdat "# ", join ( ' ', @spline ), "\n";
}

$linecc = 1;
while ( $line = $app->getline ) {
    print $ftxt $line;
    chomp $line;
    $line =~ s/^\s+//;
    @spline = split /\s+/, $line;
    print $fcsv join ( ',', @spline ), "\n";
    print $fdat "$linecc ", join ( ' ', @spline ), "\n";
    $linecc++;
}

$app->close;
$fdat->close;
$fcsv->close;
$ftxt->close;

exit 0;

