#!/usr/bin/perl -w
#
# cal_average_std.pm
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
# Author: Jenny Zhang
#
package Cal_average_std;

use strict;
use English;
use FileHandle;
use vars qw(@ISA @EXPORT);
use Exporter;

=head1 NAME

cal_average_std.pm

=head1 SYNOPSIS

read files in directories, look for value $varname, calculate average
and standard deviation

=head1 ARGUMENTS

 -inputdir <the result directory>
 -dirname <the directory name glob>
 -filename <the file which contains the numbers>
 -varname <a list of value names we are looking for>

=cut

#my ($ret1, $ret2);
#($ret1, $ret2) = calc_average_std ("../sapdb", "../sapdb/dbt3_6_2.5.62_flock*", "power", "calc_composite.out");
#print "$ret1 and $ret2\n";

@ISA = qw(Exporter);
@EXPORT = qw(cal_average_std);

sub cal_average_std
{
	my ( $inputdir, $dirname, $filename, $varname ) = @_;
	my ($hlp, $fdata, @data, @dirlist, $average, $std); 
	
	$fdata = new FileHandle;		
#	print "$inputdir/$dirname\n";
	@dirlist = glob("$inputdir/$dirname");
#	print "dirlist ", join(' ', @dirlist), "\n";
	
	for (my $j=0; $j<=$#dirlist; $j++)
	{
		unless ( $fdata->open( "< $dirlist[$j]/$filename" ) ) 
			{ die "can't open file $dirlist[$j]/$filename: $!"; }
		while ( <$fdata> )
		{
			chop;
			if ( /$varname/ )
			{
				my ( $var, $value ) = split /=/;
				print "$var is $value\n";
				$data[$j] = $value;
			}
		}
		close($fdata);
	}
	
	# calculate average and standard deviation
	$average = 0;
	my $num_element = $#data + 1;
	
	for ( my $i=0; $i<=$#data; $i++ )
	{
		$average += $data[$i];	
	}
	$average = $average/$num_element;
	
	$std = 0;
	if ($num_element > 1)
	{
		for ( my $i=0; $i<=$#data; $i++ )
		{
			$std += ( $data[$i] - $average )**2;
		}
		$std = sqrt( $std / ($num_element - 1) );
	}
	else { warn "more than 1 numbers are required"; $std = -1; }
	
	my @retvalue;
	$retvalue[0] = $average;
	$retvalue[1] = $std;
	
	wantarray() ? return @retvalue : return "@retvalue";
}
