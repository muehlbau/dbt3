#!/usr/bin/perl -w 

# CVS Strings 
# $Id: parse_sar.pl 891 2003-04-04 01:28:43Z jztpcw $ $Author: jztpcw $ $Date

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

# get sar version info so that we know whick key file to look at
sub get_sar_v {
	my $str = `sar -V 2>&1 | head -1 `;
	chomp $str;
	my @outline = split / /, $str;
	return $outline[ 2 ];
}

# get devioe name from input file
sub get_file_disknames {
	my ( $infile ) = @_;
	my ( @odsks, @line, $i );
	$i = 0;
	die "file $infile does not exist: $!" unless ( -f "$infile" );
	my $ios = new FileHandle;

	die "can not open file $infile: $!" unless ( $ios->open( "$infile" ) );
	while ( <$ios> )
	{
		next if ( ( /^Linux/ ) || ( /^$/ ) || ( /^avg/ ) || ( /^IO/ )
			|| ( /^Disk/ ) || ( /^iostat/ ) || ( /^Device/ )
			|| ( /^ / ) || ( /^Time/ ));
		@line = split /\s+/;
		# if the device is not in the list yet, add it
		# else we found all the devices
		if ( !grep {$_ eq $line[0]} @odsks )
		{
			$odsks[$i] = $line[0];
			$i++;
		}
		else
		{
			$ios->close;	
			return @odsks;
		}
	}
	$ios->close;

	return @odsks;
}

sub sar_parse {
	my ( $infile, $outfile, $comment, $option, $num_of_columns, $start_column ) = @_;

	my ( @iosdisks, @line, $iodisk, $header, @columns );
	# always use human readable file
	$header = '';

	# start from start_column
	for (my $i=0; $i<$num_of_columns; $i++)
	{
		$columns[$i] = $start_column + $i;
	}
	eval {extract_columns_rows_sar($infile, "$outfile.dat", "[0-9]+", $header, $comment, 'gnuplot', $start_column, @columns)};
	if ( $@ )
	{
		die "error executing iostat_sar: $@\n";
	}
	eval {extract_columns_rows_sar($infile, "$outfile.txt", "[0-9]+", $header, $comment, 'txt', $start_column, @columns)};
	if ( $@ )
	{
		die "error executing iostat_sar: $@\n";
	}

	return 0;
}

=head1 NAME

# parse_sar.pl

=head1 SYNOPSIS

open sar binary with option and generate gnuplot data files

=head1 ARGUMENTS

 -infile <filename> text file with iostat data
 -outfile <filename> prefix for  .dat files
 -comment <string> comment for file name
 -option < iostat command option >
 -file <filename> use configuration file for all options
 -write <filename> create configuration file 

=cut

my ( $option, $infile, $outfile, $comment, $num_cpus, $configfile, 
	$writeme, $hlp );

my ( %options, $cline, $num_columns, $start_column );

my $fcf = new FileHandle;
GetOptions(
			"infile=s"  => \$infile,
			"outfile=s" => \$outfile,
			"comment=s" => \$comment,
			"option=s" => \$option,
			"num_cpus=i" => \$num_cpus,
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

if ( $option ) { $options{ 'option' } = $option; }
elsif ( $options{ 'option' } ) {
	$option =  $options{ 'option' };
}
else
{
	die "No option $!";
}

if ( $option eq '-P' || $option eq '-A' )
{
	if ( $num_cpus ) { $options{ 'num_cpus' } = $num_cpus; }
	elsif ( $options{ 'num_cpus' } ) {
		$num_cpus =  $options{ 'num_cpus' };
	}
	else
	{
		die "number of CPU is requied for option $option";
	}

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
	$comment = "sar $option";
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

my $version = get_sar_v;
my $keyfile = "sar.$version.key";
my $header_type = 'ap';
# if the key file exists for this version
# use human readable header
if ( -f $keyfile )
{
	my @heads = eval{ get_header( $keyfile, "$option", "hr" ) };
        if ($@)
        {
                die "error get_diskheads: $@";
        }
	$start_column = shift @heads;
	$num_columns = $#heads + 1;
	# get rid of 'Device'
	my $head_str;
	$head_str = join(' ', @heads);
	$comment = $comment."\n"."#".$head_str;
	$header_type = 'hr';
}
else
{
	die "key file $keyfile is required";
}

# if key file exsits, header is read from the key files as human readable format
# else header_type is 'ap' and header is read from the $infile
if ( $option eq '-P' || $option eq '-A' )
{
	for (my $i=0; $i<$num_cpus; $i++)
	{
		eval {sar_parse( "sar $option $i -f $infile |", "$outfile.cpu$i", $comment, $option, $num_columns, $start_column)};
	}
}
else
{
	eval {sar_parse( "sar $option -f $infile |", $outfile, $comment, $option, $num_columns, $start_column)};
	if ( $@ )
	{
		die "error executing iostat_parse: $@\n";
	}
}
