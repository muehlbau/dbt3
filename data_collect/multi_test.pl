#!/usr/bin/perl -w 
# get_config.sh: get dbt3 run configuration
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
use File::Spec::Functions;
use File::Basename;
use File::Copy;
use FileHandle;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

multi_test_stats.pl

=head1 SYNOPSIS

run dbt3 test multiple times

=head1 ARGUMENTS

 -run <number of tests to run>
 -commands <the command to execute>
 -file <config filename to read config from> 
 -write <filename to write config to> 

=cut

my ( $runs, $hlp, @commands, $configfile, $writeme );

GetOptions(
	"runs=i" => \$runs,
	"help"      => \$hlp,
	"commands=s" => \@commands,
	"file=s"    => \$configfile,
	"write=s"   => \$writeme
);


my $fcf = new FileHandle;
my ( $cline, %options );
my ( $iline, $fh );

if ($hlp) { pod2usage(1); }

#read config from config file
if ( $configfile ) {
    unless ( $fcf->open( "< $configfile" ) ) {
        die "Missing config file $!";
    }
    while ( $cline = $fcf->getline ) {
        next if ( $cline =~ /^#/ );
        chomp $cline;
        my ( $var, $value ) = split /=/, $cline;
        $options{ $var } = $value;
	$_=$var;
	if (/commands/)
	{
		$#commands++;
	}
    }
    $fcf->close;
}

if ( $runs ) { $options{ 'runs' } = $runs; }
elsif ( !$options{ 'runs' } ) {
    die "No number of runs $!";
} 
else
{
	$runs=$options{ 'runs' };
}

if ($runs != ($#commands+1)) { die "the number of output directories does not match the number of commands";}

for (my $i=0; $i<=$#commands; $i++)
{
	if ( $commands[$i] )
	{
		$options{"commands$i"}= $commands[$i];
	}
	elsif ($options{"commands$i"}) 
	{
		$commands[$i]=$options{"commands$i"};
	}
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

print "Will start $runs test with command ", join (' ', @commands), "\n";

for (my $i=0; $i<$runs; $i++)
{
	system("$commands[$i]");
}
