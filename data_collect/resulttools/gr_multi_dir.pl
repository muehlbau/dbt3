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

Takes a glob to generate a list of files of gnuplot data  from one directory
Plots some of the data colums in a graph
Options from a config file or command line


=head1 ARGUMENTS

 -infile <input data file name>
 -outfile <prefix for .png and .input files >
 -dirglob <directory name >
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
	 $infile, $hlp,	$outfile, $title,   $vlabel,	 $hlabel, $bstr, $estr,
	 $xrange, $yrange, $columns, $writeme, $configfile, $dirglob, @filelist
);

GetOptions(
			"infile=s"   => \$infile,
			"outfile=s"  => \$outfile,
			"dirglob=s"  => \$dirglob,
			"title=s"	=> \$title,
			"xrange=s"   => \$xrange,
			"yrange=s"   => \$yrange,
			"vlabel=s"   => \$vlabel,
			"hlabel=s"   => \$hlabel,
			"beginstr=s" => \$bstr,
			"endstr=s"   => \$estr,
			"help"	   => \$hlp,
			"columns=s"   => \$columns,
			"write=s"	=> \$writeme,
			"file=s"	 => \$configfile
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
		$_ = $var;
	}
	$fcf->close;
}

if ( $infile ) { $options{ 'infile' } = $infile; }
elsif ( $options{ 'infile' } ) {
	$infile =  $options{ 'infile' };
}
else 
{
	die "No input file $!";
}

if ( $outfile ) { $options{ 'outfile' } = $outfile; }
elsif ( $options{ 'outfile' } ) {
	$outfile =  $options{ 'outfile' };
}
else 
{
	die "No outfile file $!";
}

if ( $dirglob ) { $options{ 'dirglob' } = $dirglob; }
elsif ( $options{ 'dirglob' } ) {
        $dirglob =  $options{ 'dirglob' };
}
else
{
        die "No dirglob file $!";
}

if ( $columns || $columns eq '0' ) { $options{ 'columns' } = $columns; }
elsif ( $options{ 'columns' } ) {
	$columns =  $options{ 'columns' };
}
else 
{
	die "No columns specifiled $!";
}

if ( $vlabel ) { $options{ 'vlabel' } = $vlabel; }
elsif ( $options{ 'vlabel' } ) {
	$vlabel =  $options{ 'vlabel' };
}
else 
{
	print "No vlable specifiled\n";
}

if ( $hlabel ) { $options{ 'hlabel' } = $hlabel; }
elsif ( $options{ 'hlabel' } ) {
	$hlabel =  $options{ 'hlabel' };
}
else 
{
	print "No hlable specifiled\n";
}

if ( $title ) { $options{ 'title' } = $title; }
elsif ( $options{ 'title' } ) {
	$title =  $options{ 'title' };
}
else 
{
	print "Using first line of data file for title \n";
}

if ( $xrange ) { $options{ 'xrange' } = $xrange; }
elsif ( $options{ 'xrange' } ) {
	$xrange =  $options{ 'xrange' };
}
else 
{
	print "XRange set to Autio\n";
}

if ( $yrange ) { $options{ 'yrange' } = $yrange; }
elsif ( $options{ 'yrange' } ) {
	$yrange =  $options{ 'yrange' };
}
else 
{
	print "YRange set to Autio\n";
}

if ( $bstr ) { $options{ 'bstr' } = $bstr; }
elsif ( $options{ 'bstr' } ) {
	$bstr =  $options{ 'bstr' };
}

if ( $estr ) { $options{ 'estr' } = $estr; }
elsif ( $options{ 'estr' } ) {
	$estr =  $options{ 'estr' };
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
=head4 HEADER PROCESSING

It is assumed that the first line in the data file is the title
The second line should be a list of the headers
We read the next line of data to see how many headers we really need

=cut 
my @dirlist;
@dirlist = glob($dirglob);

for ( my $i=0; $i<=$#dirlist; $i++)
{
	$filelist[$i] = "$dirlist[$i]/$infile";
}
print "filelist ", join ( '  ', @filelist );

unless ( $fin->open( "< $filelist[0]" ) )   { die "No data file $!"; }
unless ( $fout->open( "> $outfile.input" ) ) { die "cannot open output $!"; }
my ( $line, $ititle, @headers, @cols, $hmax );

#get title
$ititle = $fin->getline;
chomp $ititle;
$ititle =~ s/^# //;
unless ( $title ) { $title = $ititle; }

#get headline
$line = $fin->getline;
chomp $line;
$line =~ s/^#//;
# get rid of the leading spaces
$line =~ s/^\s+//;
@headers = split /\s+/, $line;

$fin->close;

@cols = split /,/, $columns;

print $fout "set title \"$title\"\n";
print $fout "set data style lines\n";
print $fout "set grid xtics ytics\n";
if ( $yrange ) {
	print $fout "set yrange [0:", $yrange, "]\n";
}
if ( $xrange ) {
	print $fout "set xrange [0:", $xrange, "]\n";
}
my $dname;
print "\n$#filelist files\n";
print $fout "plot ";
for ( my $j = 0; $j < $#filelist; $j++ ) {
	$dname = dirname( $filelist[ $j ] );
	print "dname1 is $dname\n";
	if ( $bstr ) { $dname =~ s/^$bstr//; }
	if ( $estr ) { $dname =~ s/$estr$//; }
	print "dname2 is $dname\n";
	for ( my $i = 0; $i <= $#cols; $i++ ) {
		my $cc = $cols[ $i ] + 2;	# offset for 'using' operator
		my $hc = $cols[ $i ];
		print $fout "\"", $filelist[ $j ], "\" using 1:$cc title \"",
		  $dname . "." . $headers[ $hc ], "\",\\\n";
	}
}
$dname = dirname( $filelist[ $#filelist ] );
if ( $bstr ) { $dname =~ s/^$bstr//; }
if ( $estr ) { $dname =~ s/$estr$//; }
for ( my $i = 0; $i <= $#cols; $i++ ) {
	my $cc = $cols[ $i ] + 2;	# offset for 'using' operator
	my $hc = $cols[ $i ];
	if ( $i < $#cols ) {
		print $fout "\"", $filelist[ ($#filelist) ], "\" using 1:$cc title \"",
		  $dname . $headers[ $hc ], "\",\\\n";
	} else {
		print $fout "\"", $filelist[ ($#filelist) ], "\" using 1:$cc title \"",
		  $dname .".". $headers[ $hc ], "\"\n";
	}
}

if ( $vlabel ) {
	print $fout "set ylabel \"", $vlabel, "\" \n";
}

if ( $hlabel ) {
	print $fout "set xlabel \"", $hlabel, "\" \n";
}

print $fout "set term png medium color\n";
print $fout "set output \"$outfile.png\" \n";
print $fout "replot\n";
$fout->close;

system( "gnuplot $outfile.input" );

