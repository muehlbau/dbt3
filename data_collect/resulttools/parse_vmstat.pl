#!/usr/bin/perl -w 

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use CGI qw(:standard :html3);
use Pod::Usage;

use constant DEBUG => 0;

# "@(#) $Id: parse_vmstat.pl 772 2003-02-28 22:11:13Z jztpcw $ $Date: 2003-02-28 14:11:13 -0800 (Fri, 28 Feb 2003) $ $Author: jztpcw $";

# Thanks, bryce!

=head1 NAME 

parse_vmstat.pl

=head1 SYNOPSIS

munges data from vmstat
Takes as input a text file of vmstat output 
Creates a csv file and a gnuplot data file as output

=cut

sub get_vmstat_v {
    my $str = `vmstat -V 2>&1 `;
    chomp $str;
    my @outline = split / /, $str;
    return $outline[ 2 ];
}

sub get_heads_live {
    my ( $line, @ostr );
    my $app = new FileHandle;
    unless ( $app->open( "vmstat 1 1 |" ) ) {
        return 1;
    }
    $line = $app->getline;    # skip first output
    $line = $app->getline;    # get headers
    chomp $line;
    $line =~ s/^\s+//;        # trim leading spaces
    @ostr = split /\s+/, $line;
    $line = $app->getline;    # should cause exit of app
    $app->close;
    return @ostr;
}

sub get_hr_heads {
    my $keyfile = shift;
    my ( $line, @ostr );
    my $fkey = new FileHandle;
    if ( -f $keyfile ) {
        unless ( $fkey->open( "< $keyfile" ) ) { return 1; }
        while ( ( $line = $fkey->getline ) =~ /^#/ ) {
            my $junk = $line;
        }
        chomp $line;
        @ostr = split /;/, $line;
        $fkey->close;
    } else {
        @ostr = get_heads_live;
    }
    return @ostr;
}

sub get_app_heads {
    my $keyfile = shift;
    my ( $line, @ostr );
    my $fkey = new FileHandle;
    if ( -f $keyfile ) {
        unless ( $fkey->open( "< $keyfile" ) ) { return 1; }
        while ( ( $line = $fkey->getline ) =~ /^#/ ) {
            my $junk = $line;
        }

        # walk past the first non-comment line
        while ( ( $line = $fkey->getline ) =~ /^#/ ) {
            my $junk = $line;
        }
        chomp $line;
        @ostr = split /;/, $line;
        $fkey->close;
    } else {
        @ostr = get_heads_live;
    }
    return @ostr;
}

sub vmstat_parse {
    my ( $infile, $outfile, $comment, @headers ) = @_;

    my ( $lncnt, $inline, $datfh, $infh, $csvfh, $datfn, $infn, $csvfn );

    return 1 unless ( -f "$infile" );
    print "in vmstat_parse\n" if DEBUG;
    $datfn = catdir $outfile . ".dat";
    $csvfn = catdir $outfile . ".csv";
    $infn  = $infile;

    $datfh = new FileHandle;
    $infh  = new FileHandle;
    $csvfh = new FileHandle;

    unless ( $datfh->open( ">$datfn" ) ) { return 2; }
    unless ( $csvfh->open( ">$csvfn" ) ) { return 3; }
    unless ( $infh->open( "$infn" ) )    { return 4; }

    print $datfh "# $comment \n";
    print $datfh "# ", join ( ' ', @headers ), "\n";
    print $csvfh "$comment\n";
    print $csvfh join ( ',', @headers ), "\n";

    $lncnt = 0;
    for $inline ( <$infh> ) {
        chomp $inline;
        $inline =~ s/^\s*//;
        next if ( $inline !~ /^\d/ );
        my @cols = split /\s+/, $inline;
        print "vline ", join ( ':', @cols ), "\n" if DEBUG;
        print $csvfh join ( ',', @cols ), "\n";
        print $datfh "$lncnt ", join ( '  ', @cols ), "\n";
        $lncnt++;
    }
    $csvfh->close;
    $infh->close;
    $datfh->close;

    return 0;

}

# START HERE BUBBA

=head1 ARGUMENTS

  -file <config file> - All config file options can be overwritten by command line
  -infile <filename> - A text file contain vmstat output
  -outfile <filename prefix> - program will create .dat and .csv files
  -comment <string> - text for first line of output files
  -version <Vmstat version (procps) >  - Version is auto-detected otherwise
  -write <filename> - write a configuration file for repeated runs

=cut

my ( $infile, $outfile, $comment, $configfile, $pver, $writeme, $hlp );

my ( %options, @heads, $cline, $line, );

GetOptions(
            "infile=s"  => \$infile,
            "outfile=s" => \$outfile,
            "comment=s" => \$comment,
            "help"      => \$hlp,
            "write=s"   => \$writeme,
            "version=s" => \$pver,
            "file=s"    => \$configfile
);

my $fin  = new FileHandle;
my $fdat = new FileHandle;
my $fcsv = new FileHandle;
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
    $options{ 'comment' } = "Vmstat data";
}
if ( $pver ) { $options{ 'version' } = $pver; }
elsif ( !$options{ 'version' } ) {
    $pver = get_vmstat_v();
    $options{ 'version' } = $pver;
}

print "parsing vmstat\n" if DEBUG;
my $vmkey = "vmstat." . $pver . ".key";
@heads = get_hr_heads( $vmkey );

# vmstat_parse { my ( $indir, $infile, $outdir, $outfile, $comment, @headers ) = @_;
my $res = vmstat_parse(
                        $options{ 'infile' },
                        $options{ 'outfile' },
                        $options{ 'comment' },
                        @heads
);
if ( $res > 0 ) { print STDERR "vmstat problems results = $res\n"; }

if ( $writeme ) {
    my $ncf = new FileHandle;
    unless ( $ncf->open( "> $writeme" ) ) { die "can't open file $!"; }
    my $name;
    foreach $name ( keys( %options ) ) {
        print $ncf $name, "=", $options{ $name }, "\n";
    }
    $ncf->close;
}
