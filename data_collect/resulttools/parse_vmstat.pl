#!/usr/bin/perl -w 

# CVS Strings 
# $Id: parse_vmstat.pl 1213 2005-03-04 17:10:26Z fimath $ $Author: fimath $ $Date

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use FileHandle;
use Pod::Usage;
use Env qw(DBT3_INSTALL_PATH SID DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE";
use Data_report;

use constant DEBUG => 0;

# get number of columsn
sub get_num_columns {
	my ( $infile ) = @_;
	my ( @line, $num_columns );

	$num_columns = 0;
	my $ios = new FileHandle;
	die "can not open file $infile: $!" unless ( $ios->open( "$infile" ) );
	while ( <$ios> )
	{
		next if ( !/ r  b/ );
		#get rid of leading space
		s/^\s+//;
		@line = split /\s+/;
		$num_columns  = $#line + 1;
		last;
	}
	$ios->close;
	if ( $num_columns == 0) { warn "can not find [0-9] in file $infile";}
	return $num_columns;
}

sub vmstat_parse {
	my ( $infile, $outfile, $comment, $header_type, $num_of_columns ) = @_;

	# hack 
	my ( $header, @columns );

	if ( $header_type eq 'hr' )
	{
		$header = '';
	}
	else
	{
		$header = 'r  b';
	}

	for (my $i=0; $i<$num_of_columns; $i++)
	{
		$columns[$i] = $i;
	}
	eval {extract_columns_rows($infile, "$outfile.dat", "[0-9]+", $header, $comment, 'gnuplot', @columns)};
	if ( $@ )
	{
		die "error executing iostat_parse: $@\n";
	}

	return 0;
}

=head1 NAME

# parse_vmstat.pl

=head1 SYNOPSIS

parse vmstat output and generate gnuplot data file

=head1 ARGUMENTS

 -infile <filename: text file with iostat data >
 -outfile <filename: prefix for .dat file >
 -comment <string> comment for file name
 -file <filename> use configuration file for all options
 -write <filename> create configuration file 

=cut

my ( $infile, $outfile, $comment, $configfile, $writeme, $hlp );

my ( %options, $cline, $line, $num_columns );

my $fcf = new FileHandle;
GetOptions(
			"infile=s"  => \$infile,
			"outfile=s" => \$outfile,
			"comment=s" => \$comment,
			"help"	  => \$hlp,
			"write=s"   => \$writeme,
			"file=s"	=> \$configfile
);

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
elsif ( $options{ 'infile' } ) {
	$infile =  $options{ 'infile' };
}
else
{
	die "No infile $!";
}

if ( $outfile ) { $options{ 'outfile' } = $outfile; }
elsif ( $options{ 'outfile' } ) {
	$outfile =  $options{ 'outfile' };
}
else
{
	die "No outfile $!";
}

if ( $comment ) { $options{ 'comment' } = $comment; }
elsif ( $options{ 'comment' } ) {
	$comment =  $options{ 'comment' };
}
else
{
	$comment = "iostat";
	$options{ 'comment' } = $comment;
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

my $version = get_vmstat_version();
my $keyfile = "vmstat.$version.key";
my $header_type = 'ap';
# if the key file exists for this version
# use human readable header
if ( -f $keyfile )
{
	my @heads = eval{ get_header( $keyfile, "", "hr" ) };
        if ($@)
        {
                die "error get_diskheads: $@";
        }
	$num_columns = $#heads + 1;
	my $head_str;
	$head_str = join(' ', @heads);
	$comment = $comment."\n"."#".$head_str;
	$header_type = 'hr';
}
else
{
	#get number of columns in the file
	$num_columns = get_num_columns($infile);
}

# if key file exsits, header is read from the key files as human readable format
# else header_type is 'ap' and header is read from the $infile
eval {vmstat_parse( $infile, $outfile, $comment, $header_type, $num_columns)};
if ( $@ )
{
	die "error executing iostat_parse: $@\n";
}

