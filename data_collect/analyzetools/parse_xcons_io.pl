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
elsif ( !$options{ 'infile' } ) {
	die "No input file $!";
}

if ( $outdir ) { $options{ 'outdir' } = $outdir; }
elsif ( !$options{ 'outdir' } ) {
	die "No outdir $!";
}

if ( $paramfile ) { $options{ 'paramfile' } = $paramfile; }
elsif ( !$options{ 'paramfile' } ) {
	die "No paramfile file $!";
}

my $fparam = new FileHandle;

#parse paramfile and get devspace list
unless ( $fparam->open( "< $paramfile" ) )   { die "No parameter file $!"; }
my ($line, @content, $datadev_index, $logdev_index);

$datadev_index=0;
$logdev_index=0;
while (<$fparam>)
{
	if ( /^SYSDEV_001/ ) {	
		chop $_;
		@content=split / *\t/, $_;
		$sysdev=$content[2];
		print "sysdev $sysdev\n";
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
	unless ( $flogio[$i]->open( "> $outdir/logio$i.dat" ) ) { die "cannot open output $!"; }
	my $ttt;
	$ttt =  $flogio[$i];
	print $ttt "#device name $logdev_list[$i]\n";
	print $ttt "#Devspace\tRead(s)\tWrite(s)\tTotal\n";
}

#open io file for sys device
unless ( $fsysio->open( "> $outdir/sysio.dat" ) ) { die "cannot open output $!"; }
print $fsysio "#device name $sysdev\n";
print $fsysio "#Devspace\tRead(s)\tWrite(s)\tTotal\n";

#open io file for data devices
for (my $i=0; $i<=$#datadev_list; $i++) {
	$fdataio[$i] = new FileHandle;
	unless ( $fdataio[$i]->open( "> $outdir/dataio$i.dat" ) ) { die "cannot open output $!"; }
	my $ttt;
	$ttt =  $fdataio[$i];
	print $ttt "#device name $datadev_list[$i]\n";
	print $ttt "#Devspace\tRead(s)\tWrite(s)\tTotal\n";
}

#open io file for sys device
unless ( $ftotalio->open( "> $outdir/totalio.dat" ) ) { die "cannot open output $!"; }
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
				print $fsysio "$xcons_index\t$fields[0]\t$diffread\t$diffwrite\t$difftotal\n";
			}
			$sysread1=$fields[2];
			$syswrite1=$fields[3];
			$systotal1=$fields[4];
		}
		elsif ( /^total I\/O/ )
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

$fsysio->close;
$ftotalio->close;
for (my $i=0; $i<=$#logdev_list; $i++)
{
	$flogio[$i]->close;
}
for (my $i=0; $i<=$#datadev_list; $i++)
{
	$fdataio[$i]->close;
}
