#!/usr/bin/perl -w

use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Pod::Usage;
use Shell qw(grep awk);

=head1 NAME

parase_xcons_io.pl

=head1 SYNOPSIS

Takes a glob to ananlyze a list of x_cons output files
and generate disk io activity files
Options from a config file or command line

=head1 ARGUMENTS

 -infile <input data file glob pattern>
 -outdir <output directory >
 -file <config file> 
 -write <create new config file >

=cut 

my (
	 $infile, $hlp,	$outdir, $writeme, 
	 $configfile, @filelist
);

GetOptions(
			"infile=s"  => \$infile,
			"outdir=s" => \$outdir,
			"help"	  => \$hlp,
			"write=s"   => \$writeme,
			"file=s"	=> \$configfile
);

my $fcf  = new FileHandle;
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

if ( $outdir ) { $options{ 'outdir' } = $outdir; }
elsif ( !$options{ 'outdir' } ) {
	die "No outdir $!";
}

#get a list of the files using glob, but the order is wrong, so I just got
#the number of files
@filelist = glob("$infile");
print "filelist $#filelist", join ( '  ', @filelist );

my $fout = new FileHandle; 

#open output file
unless ( $fout->open( "> $outdir/xcons_cpu.dat" ) ) { die "cannot open output $!"; }
print $fout "#threads running vs sleeping\n";
print $fout "#Sleeping\tRuning\n";

my $xcons_index;
my $fxconsin = new FileHandle;
my $xcons_name;
my @fields;

for ($xcons_index=0; $xcons_index<=$#filelist; $xcons_index++ ) {
	#get xcons file name
	$xcons_name=$infile;
	$xcons_name=~s/\*/$xcons_index/;
	my $sleep = 0;
	my $run = 0;
	my $find_flag = 0;

	unless ( $fxconsin->open( "< $xcons_name" )) { die "cannot open $xcons_name $!"; }
	while (<$fxconsin>)
	{
		if ( /\*US/ )
		{
			chop $_;
			@fields=split / +/, $_;
			if ( $fields[3] eq 'Sleeping' ) { $sleep++; }
			elsif ( $fields[3] eq 'Running' ) { $run++; }
			else { print "unexpected state $fields[2]\n"; }
			$find_flag = 1;
		}
		else
		{
			#if this is the first line after we found the lines
			if ( $find_flag == 1 )
			{
				print $fout "$xcons_index\t$sleep\t$run\n";
				$fxconsin->close;
				last;
			}
		}
	}
}

$fout->close;
