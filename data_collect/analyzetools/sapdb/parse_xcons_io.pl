#!/usr/bin/perl -w
# parse_xcons_io.sh: parse sapdb xcons output to get io info
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
# March 2003


use strict;
use English;
use Getopt::Long;
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Pod::Usage;
use Shell qw(grep awk);
use Env qw(DBT3_INSTALL_PATH SID DBT3_PERL_MODULE);
use lib "$DBT3_PERL_MODULE";
use Data_report;

=head1 NAME

parase_xcons_io.pl

=head1 SYNOPSIS

Takes a glob to ananlyze a list of x_cons output files
and generate disk io activity files
Options from a config file or command line

=head1 ARGUMENTS

 -infile <input data file glob pattern>
 -outdir <output directory >
 -paramfile < SAP DB parameter file to find out the device name >
 -file <config file> 
 -write <create new config file >

=cut 

my (
	$infile, $hlp,	$outdir, $paramfile, $writeme,
	$configfile, @filelist, $sysdev, @logdev_list, @datadev_list
);

GetOptions(
			"infile=s"  => \$infile,
			"outdir=s" => \$outdir,
			"paramfile=s" => \$paramfile,
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
elsif ( $options{ 'infile' } ) {
	$infile = $options{ 'infile' };
}
else
{
	die "No input file $!";
}

if ( $outdir ) { $options{ 'outdir' } = $outdir; }
elsif ( $options{ 'outdir' } ) {
	$outdir = $options{ 'outdir' };
}
else
{
	die "No outdir $!";
}

if ( $paramfile ) { $options{ 'paramfile' } = $paramfile; }
elsif ( $options{ 'paramfile' } ) {
	$paramfile = $options{ 'paramfile' };
}
else
{
	die "No paramfile file $!";
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

my $fparam = new FileHandle;

#parse paramfile and get devspace list
unless ( $fparam->open( "< $paramfile" ) )   { die "No parameter file $!"; }
my ($line, @content, $datadev_index, $logdev_index, $sapdb_version);

$sapdb_version = get_sapdb_version();

$datadev_index=0;
$logdev_index=0;
while (<$fparam>)
{
	if ( $sapdb_version =~ /7.3/ )
	{
		if ( /^SYSDEV_001/ ) {	
			chop $_;
			@content=split / *\t/, $_;
			$sysdev=$content[2];
			print "sysdev $sysdev\n";
		}
	}
	if ( /^ARCHIVE_LOG_0/ ) {
		chop $_;
		@content=split / *\t/, $_;
		$logdev_list[$logdev_index]=$content[2];
		print "logdev $#logdev_list: $logdev_list[$logdev_index]\n";
		$logdev_index=$logdev_index+1;
	}
	if ( /^DATADEV_0/ ) {
		chop $_;
		@content=split / *\t/, $_;
		$datadev_list[$datadev_index]=$content[2];
		print "datadev $datadev_index: $datadev_list[$datadev_index]\n";
		$datadev_index=$datadev_index+1;
	}
}
$fparam->close;

#get a list of the files using glob, but the order is wrong, so I just got
#number of files
@filelist = glob("$infile");
print "filelist $#filelist", join ( '  ', @filelist );

my @flogio; 
my $fsysio = new FileHandle;
my @fdataio;
my $ftotalio = new FileHandle;

#open io file for log devices
print "$#datadev_list data devices\n";
for (my $i=0; $i<=$#logdev_list; $i++) {
	$flogio[$i] = new FileHandle;
	unless ( $flogio[$i]->open( "> $outdir/xcons_logio$i.dat" ) ) { die "cannot open output $!"; }
	my $ttt;
	$ttt =  $flogio[$i];
	print $ttt "#device name $logdev_list[$i]\n";
	print $ttt "#Devspace\tRead(s)\tWrite(s)\tTotal\n";
}

if ( $sapdb_version =~ /7.3/ )
{
	#open io file for sys device
	unless ( $fsysio->open( "> $outdir/xcons_sysio.dat" ) ) { die "cannot open output $!"; }
	print $fsysio "#device name $sysdev\n";
	print $fsysio "#Devspace\tRead(s)\tWrite(s)\tTotal\n";
}

#open io file for data devices
for (my $i=0; $i<=$#datadev_list; $i++) {
	$fdataio[$i] = new FileHandle;
	unless ( $fdataio[$i]->open( "> $outdir/xcons_dataio$i.dat" ) ) { die "cannot open output $!"; }
	my $ttt;
	$ttt =  $fdataio[$i];
	print $ttt "#device name $datadev_list[$i]\n";
	print $ttt "#Devspace\tRead(s)\tWrite(s)\tTotal\n";
}

#open io file for total
unless ( $ftotalio->open( "> $outdir/xcons_totalio.dat" ) ) { die "cannot open output $!"; }
print $ftotalio "#total io\n";
print $ftotalio "#Devspace\tRead(s)\tWrite(s)\tTotal\n";

my $xcons_index;
my $fxconsin = new FileHandle;
my $xcons_name;
my @fields;
my $sysread1;
my $syswrite1;
my $systotal1;
my $totalread1;
my $totalwrite1;
my $totaltotal1;
my @logread1;
my @logwrite1;
my @logtotal1;
my @dataread1;
my @datawrite1;
my @datatotal1;

for ($xcons_index=0; $xcons_index<=$#filelist; $xcons_index++ ) {
	#get xcons file name
	$xcons_name=$infile;
	$xcons_name=~s/\*/$xcons_index/;

	unless ( $fxconsin->open( "< $xcons_name" )) { die "cannot open $xcons_name $!"; }
	while (<$fxconsin>)
	{
		if ( $sapdb_version =~ /7.3/ )
		{
			if ( /^$sysdev/i )
			{
				chop $_;
				@fields=split / +/, $_;
				if ( $xcons_index>0 )
				{
					my $diffread;
					my $diffwrite;
					my $difftotal;
					$diffread=$fields[2]-$sysread1;
					$diffwrite=$fields[3]-$syswrite1;
					$difftotal=$fields[4]-$systotal1;
					print $fsysio 
						"$xcons_index\t$fields[0]\t$diffread\t$diffwrite\t$difftotal\n";
				}
				$sysread1=$fields[2];
				$syswrite1=$fields[3];
				$systotal1=$fields[4];
			}
		}
		if ( /^total I\/O/ )
		{
			chop $_;
			@fields=split / +/, $_;
                        @fields=split / +/, $_;
                        if ( $xcons_index>0 )
                        {
                                my $diffread;
                                my $diffwrite;
                                my $difftotal;
                                $diffread=$fields[2]-$totalread1;
                                $diffwrite=$fields[3]-$totalwrite1;
                                $difftotal=$fields[4]-$totaltotal1;
                                print $ftotalio "$xcons_index\t$fields[0]\t$diffread\t$diffwrite\t$difftotal\n";
                        }
                        $totalread1=$fields[2];
                        $totalwrite1=$fields[3];
                        $totaltotal1=$fields[4];
			# I know this is the last line I want 
			$fxconsin->close;
			last;	
		}
		else 
		{
			for (my $i=0; $i<=$#logdev_list; $i++)
			{
				my $devname;
				$devname=$logdev_list[$i];
				if ( /^$devname/ )
				{
		                        chop $_;
               			        @fields=split / +/, $_;
		                        if ( $xcons_index>0 )
               			        {
						my $diffread;
						my $diffwrite;
						my $difftotal;
						$diffread=$fields[2]-$logread1[$i];
						$diffwrite=$fields[3]-$logwrite1[$i];
						$difftotal=$fields[4]-$logtotal1[$i];
						my $ttt;
						$ttt=$flogio[$i];
						print $ttt "$xcons_index\t$fields[0]\t$diffread\t$diffwrite\t$difftotal\n";
					}
					$logread1[$i]=$fields[2];
					$logwrite1[$i]=$fields[3];
					$logtotal1[$i]=$fields[4];
				}
			}
			for (my $i=0; $i<=$#datadev_list; $i++)
			{
				my $devname;
				$devname=$datadev_list[$i];
				if ( /^$devname/ )
				{
		                        chop $_;
               			        @fields=split / +/, $_;
		                        if ( $xcons_index>0 )
               			        {
						my $diffread;
						my $diffwrite;
						my $difftotal;
#						$diffread=($fields[2]-$dataread1[$i])*16/60;
#						$diffwrite=($fields[3]-$datawrite1[$i])*16/60;
#						$difftotal=($fields[4]-$datatotal1[$i])*16/60;
						$diffread=$fields[2]-$dataread1[$i];
						$diffwrite=$fields[3]-$datawrite1[$i];
						$difftotal=$fields[4]-$datatotal1[$i];
						my $ttt;
						$ttt=$fdataio[$i];
						print $ttt "$xcons_index\t$fields[0]\t$diffread\t$diffwrite\t$difftotal\n";
					}
					$dataread1[$i]=$fields[2];
					$datawrite1[$i]=$fields[3];
					$datatotal1[$i]=$fields[4];
				}
			}
		}
	}
} 

if ( $sapdb_version =~ /7.3/ )
{
	$fsysio->close;
}
$ftotalio->close;
for (my $i=0; $i<=$#logdev_list; $i++)
{
	$flogio[$i]->close;
}
for (my $i=0; $i<=$#datadev_list; $i++)
{
	$fdataio[$i]->close;
}
