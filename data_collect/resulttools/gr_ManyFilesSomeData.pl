#!/usr/bin/perl -w

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Pod::Usage;

=head1 NAME

gr_ManyFilesSomeData.pl

=head1 SYNOPSIS

Takes a glob to generate a list of files of gnuplot data 
Plots some of the data colums in a graph
Options from a config file or command line


=head1 ARGUMENTS

 -infile <input data file glob pattern>
 -outfile <prefix for .png and .input files >
 -title <graph title>
 -xrange 
 -yrange
 -vlabel ( Y axis label )
 -hlabel ( X axis label ) 
 -file <config file> 
 -beginstring <string> - we use filename as graph line label. This string will be removed from the begining of the
	file name
 -endstring - this string will be trimmed from the end
 -write <create new config file >
 -colums - comma separated list of data colums, numbered from ZERO
All options require parameters
Options on command line over-rule config file

=cut 

my (
     $infile, $hlp,    $outfile, $title,   $vlabel,     $hlabel, $bstr, $estr,
     $xrange, $yrange, $columns, $writeme, $configfile, @filelist
);

GetOptions(
            "infile=s"   => \$infile,
            "outfile=s"  => \$outfile,
            "title=s"    => \$title,
            "xrange=s"   => \$xrange,
            "yrange=s"   => \$yrange,
            "vlabel=s"   => \$vlabel,
            "hlabel=s"   => \$hlabel,
            "beginstr=s" => \$bstr,
            "endstr=s"   => \$estr,
            "help"       => \$hlp,
            "colums=s"   => \$columns,
            "write=s"    => \$writeme,
            "file=s"     => \$configfile
);

my $fcf  = new FileHandle;
my $fin  = new FileHandle;
my $fout = new FileHandle;
my ( $cline, %options );

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

if ( $columns ) { $options{ 'columns' } = $columns; }
elsif ( !$options{ 'columns' } ) {
    die "No colums specified $!";
}

if ( $vlabel ) { $options{ 'vlabel' } = $vlabel; }
elsif ( !$options{ 'vlabel' } ) {
    print "No vertical label\n";
}

if ( $hlabel ) { $options{ 'hlabel' } = $hlabel; }
elsif ( !$options{ 'hlabel' } ) {
    print "No horizontal label\n";
}

if ( $title ) { $options{ 'title' } = $title; }
elsif ( !$options{ 'title' } ) {
    print "Using first line of data file for title \n";
}

if ( $xrange ) { $options{ 'xrange' } = $xrange; }
elsif ( !$options{ 'xrange' } ) {
    print "Range set to Autio\n";
}

if ( $yrange ) { $options{ 'yrange' } = $yrange; }
elsif ( !$options{ 'yrange' } ) {
    print "Range set to Autio\n";
}

if ( $bstr ) { $options{ 'bstr' } = $bstr }
if ( $estr ) { $options{ 'estr' } = $estr }

=head4 HEADER PROCESSING

It is assumed that the first line in the data file is the title
The second line should be a list of the headers
We read the next line of data to see how many headers we really need

=cut 

my $ofname = $options{ 'outfile' };
print "input file is $options{ 'infile' }\n";
@filelist = glob( $options{ 'infile' } );
print "filelist ", join ( '  ', @filelist );

unless ( $fin->open( "< $filelist[0]" ) )   { die "No data file $!"; }
unless ( $fout->open( "> $ofname.input" ) ) { die "cannot open output $!"; }
my ( $line, $ititle, @headers, @cols, $hmax );

$ititle = $fin->getline;
chomp $ititle;
$ititle =~ s/^# //;
unless ( $options{ 'title' } ) { $options{ 'title' } = $ititle; }

$line = $fin->getline;
chomp $line;
$line =~ s/^# //;
@headers = split /\s+/, $line;

# shift @headers;    # dump the comment char

$fin->close;

@cols = split /,/, $options{ 'columns' };

print $fout "set title \"$options{ 'title' }\"\n";
print $fout "set data style lines\n";
print $fout "set grid xtics ytics\n";
if ( $options{ 'yrange' } ) {
    print $fout "set yrange [", $options{ 'yrange' }, "]\n";
}
if ( $options{ 'xrange' } ) {
    print $fout "set xrange [", $options{ 'xrange' }, "]\n";
}
my $bname;
print "\n$#filelist files\n";
print $fout "plot ";
for ( my $j = 0; $j < $#filelist; $j++ ) {
    $bname = basename( $filelist[ $j ] );
    if ( $options{ 'bstr' } ) { $bname =~ s/^$options{'bstr'}//; }
    if ( $options{ 'estr' } ) { $bname =~ s/$options{'estr'}$//; }
    for ( my $i = 0; $i <= $#cols; $i++ ) {
        my $cc = $cols[ $i ] + 2;    # offset for 'using' operator
        my $hc = $cols[ $i ];
        print $fout "\"", $filelist[ $j ], "\" using 1:$cc title \"",
          $bname . $headers[ $hc ], "\",\\\n";
    }
}
$bname = basename( $filelist[ $#filelist ] );
if ( $options{ 'bstr' } ) { $bname =~ s/^$options{'bstr'}//; }
if ( $options{ 'estr' } ) { $bname =~ s/$options{'estr'}$//; }
for ( my $i = 0; $i <= $#cols; $i++ ) {
    my $cc = $cols[ $i ] + 2;    # offset for 'using' operator
    my $hc = $cols[ $i ];
    if ( $i < $#cols ) {
        print $fout "\"", $filelist[ ($#filelist) ], "\" using 1:$cc title \"",
          $bname . $headers[ $hc ], "\",\\\n";
    } else {
        print $fout "\"", $filelist[ ($#filelist) ], "\" using 1:$cc title \"",
          $bname . $headers[ $hc ], "\"\n";
    }
}

if ( $options{ 'vlabel' } ) {
    print $fout "set ylabel \"", $options{ 'vlabel' }, "\" \n";
}

if ( $options{ 'hlabel' } ) {
    print $fout "set xlabel \"", $options{ 'hlabel' }, "\" \n";
}

print $fout "set term png medium color\n";
print $fout "set output \"$ofname.png\" \n";
print $fout "replot\n";
$fout->close;

system( "gnuplot $ofname.input" );

if ( $writeme ) {
    my $ncf = new FileHandle;
    unless ( $ncf->open( "> $writeme" ) ) { die "can't open file $!"; }
    my $name;
    foreach $name ( keys( %options ) ) {
        print $ncf $name, "=", $options{ $name }, "\n";
    }
    $ncf->close;
}
