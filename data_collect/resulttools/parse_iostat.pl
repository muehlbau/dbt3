#!/usr/bin/perl -w 

# CVS Strings 
# $Id: parse_iostat.pl 898 2003-04-05 00:25:23Z jztpcw $ $Author: jztpcw $ $Date

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

=head1 NAME

parse_iostat.pl

=head1 SYNOPSIS

Takes a text file produced by iostat and extracts all the disk information from same

=cut

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

# get number of columsn
sub get_num_columns {
	my ( $infile ) = @_;
	my ( @line, $num_columns );

	$num_columns = 0;
	my $ios = new FileHandle;
	die "can not open file $infile: $!" unless ( $ios->open( "$infile" ) );
	while ( <$ios> )
	{
		next if ( !/^Device/ );
		@line = split /\s+/;
		$num_columns  = $#line + 1;
		last;
	}
	$ios->close;
	if ( $num_columns == 0) { warn "can not find 'Device' in file $infile";}
	return $num_columns;
}

sub iostat_parse {
	my ( $infile, $diskout, $cpuout, $comment, $opt, $header_type, $num_of_columns ) = @_;

	my ( @iosdisks, @line, $iodisk, $header, @columns );
	@iosdisks = get_file_disknames( $infile );
	if ( $header_type eq 'hr' )
	{
		$header = '';
	}
	else
	{
		$header = 'Device';
	}

	# these three generate cpu info too
	if ( $opt eq '-t' || $opt eq '-k' || $opt eq '-x' )
	{
		eval {extract_columns_rows($infile, "$cpuout.dat", "[0-9]+", "avg-cpu:", 'gnuplot', (0,1,2,3,4))};
		if ( $@ )
		{
			die "error executing iostat_parse: $@\n";
		}
	}
	
	# get rid of device name, we start from the column 1
	$num_of_columns--;
	for (my $i=0; $i<$num_of_columns; $i++)
	{
		$columns[$i] = $i+1;
	}
	# create files for each disk
	foreach $iodisk ( @iosdisks ) {
		print "in disk $iodisk\n" if DEBUG;
		# -d -k and -t will produce the same info
		# CPU info produced by -k and -t are lost
		# Time stamp produced by -t is lost
		if ( $opt eq '-d' || $opt eq '-t' || $opt eq '-k' )
		{
			extract_columns_rows($infile, "$diskout.$iodisk.dat", $iodisk, $header, $comment, 'gnuplot', @columns);
			eval {extract_columns_rows($infile, "$diskout.$iodisk.dat", $iodisk, $header, $comment, 'gnuplot', @columns)};
			if ( $@ )
			{
				die "error executing iostat_parse: $@\n";
			}
		}
		elsif ( $opt eq '-x' )
		{
			extract_columns_rows($infile, "$diskout.$iodisk.dat", $iodisk, $header, $comment, 'gnuplot', @columns);
			eval{extract_columns_rows($infile, "$diskout.$iodisk.dat", $iodisk, $header, $comment, 'gnuplot', @columns)};
			if ( $@ )
			{
				die "error executing iostat_parse: $@\n";
			}
		}
	}

	return 0;
}

=head1 NAME

# parse_iostat.pl

=head1 SYNOPSIS

parse iostat output and generate gnuplot data files for each disk

=head1 ARGUMENTS

 -infile <filename> text file with iostat data
 -diskout <filename> prefix for disk .dat files
 -cpuout <filename> prefix for cpu .dat files
 -comment <string> comment for file name
 -option < iostat command option >
 -file <filename> use configuration file for all options
 -write <filename> create configuration file 

=cut

my ( $option, $infile, $diskout, $cpuout, $comment, $configfile, 
	$writeme, $hlp );

my ( %options, $cline, $line, $num_columns, $os_version, $iostat_version,
	$iostat_path);

my $fcf = new FileHandle;
GetOptions(
			"infile=s"  => \$infile,
			"diskout=s" => \$diskout,
			"cpuout=s" => \$cpuout,
			"comment=s" => \$comment,
			"help"	  => \$hlp,
			"option=s" => \$option,
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

# cpu output filename is reqired
if ( $option eq '-k' || $option eq '-t' )
{
	if ( $cpuout ) { $options{ 'cpuout' } = $cpuout; }
	elsif ( $options{ 'cpuout' } ) {
		$cpuout =  $options{ 'cpuout' };
	}
	else
	{
		die "No cpuout $!";
	}
}

if ( $diskout ) { $options{ 'diskout' } = $diskout; }
elsif ( $options{ 'diskout' } ) {
	$diskout =  $options{ 'diskout' };
}
else
{
	die "No diskout $!";
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

$os_version = get_os_version;

# this is used my system, you might need to change it
if ( $os_version =~ /2\.4\./ )
{
	$iostat_path = "/usr/bin";
}
elsif ( $os_version =~ /2\.5\./ )
{
	$iostat_path = "/usr/local/bin";
}

$iostat_version = get_iostat_version($iostat_path);
print "os is $os_version, iostat is  $iostat_version\n";

my $keyfile = "iostat.$iostat_version.key";
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
	$num_columns = $#heads + 1;
	# get rid of 'Device'
	shift @heads;
	my $head_str;
	$head_str = join(' ', @heads);
	$comment = $comment."\n"."#".$head_str;
	$header_type = 'hr';
}
else
{
	print "a file file is recommended\n";
	#get number of columns in the file
	$num_columns = get_num_columns($infile);
}

# if key file exsits, header is read from the key files as human readable format
# else header_type is 'ap' and header is read from the $infile
eval {iostat_parse( $infile, $diskout, $cpuout, $comment, $option, $header_type, $num_columns)};
if ( $@ )
{
	die "error executing iostat_parse: $@\n";
}

