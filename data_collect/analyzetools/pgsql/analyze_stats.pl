#!/usr/bin/perl -w

# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Mark Wong & Open Source Development Lab, Inc.
#
# 4 September 2003
# 
# 30 January 2003
# Updated for DBT-3

use strict;
use Getopt::Long;

my $stats_dir;
my $phase;

GetOptions(
	"directory=s" => \$stats_dir,
	"phase=s" => \$phase
);

unless ( $stats_dir ) {
	print "usage: analyze_stats.pl --if <directory>\n";
	exit 1;
}

my @index_names = ( "supplier_pkey", "part_pkey", "partsupp_pkey",
	"customer_pkey", "orders_pkey", "lineitem_pkey", "nation_pkey",
	"region_pkey", "i_l_shipdate", "i_l_suppkey_partkey",
	"i_l_partkey", "i_l_suppkey", "i_l_receiptdate", "i_l_orderkey",
	"i_l_orderkey_quantity", "i_c_nationkey", "i_o_orderdate",
	"i_o_custkey", "i_s_nationkey", "i_ps_partkey", "i_ps_suppkey",
	"i_n_regionkey" );

my @table_names = ( "supplier", "part", "partsupp", "customer", "orders",
	"lineitem", "nation", "region", "time_statistics" );

my $index;
foreach $index ( @index_names) {
	# Split indexes_scan.out into individual files by index.
	`cat $stats_dir/$phase.indexes_scan.out | grep $index | awk '{ print NR, \$11 }' > $stats_dir/$phase.$index.index_scan.data`;

	# Recreate the files to be incremental instead of cumulative.
	open( FH, "< $stats_dir/$phase.$index.index_scan.data" )
		or die "Couldn't open $phase.$index.index_scan.data for reading: $!\n";
	my $line;
	my @data = ();
	while ( defined( $line = <FH> ) ) {
		my @raw_data = split / /, $line;
		push @data, $raw_data[ 1 ];
	}
	close FH;
	`echo "0 0" > $stats_dir/$phase.$index.index_scan.data`;
	for ( my $i = 1; $i < scalar( @data ); $i++ ) {
		my $newval = $data[ $i ] - $data[ $i - 1 ];
		`echo "$i $newval" >> $stats_dir/$phase.$index.index_scan.data`;
	}

	# Split index_info.out into individual files by index.
	`cat $stats_dir/$phase.index_info.out | grep $index | awk '{ print NR, \$9 }' > $stats_dir/$phase.$index.index_info.data`;

	# Recreate the files to be incremental instead of cumulative.
	open( FH, "< $stats_dir/$phase.$index.index_info.data" )
		or die "Couldn't open $index.index_info.data for reading: $!\n";
	@data = ();
	while ( defined( $line = <FH> ) ) {
		my @raw_data = split / /, $line;
		push @data, $raw_data[ 1 ];
	}
	close FH;
	`echo "0 0" > $stats_dir/$phase.$index.index_info.data`;
	for ( my $i = 1; $i < scalar( @data ); $i++ ) {
		my $newval = $data[ $i ] - $data[ $i - 1 ];
		`echo "$i $newval" >> $stats_dir/$phase.$index.index_info.data`;
	}
}

my $table;
foreach $table ( @table_names ) {
	# Split table_info.out into individual files by table.
	`cat $stats_dir/$phase.table_info.out | grep $table | awk '{ print NR, \$5 }' > $stats_dir/$phase.$table.table_info.data`;

	# Recreate the files to be incremental instead of cumulative.
	open( FH, "< $stats_dir/$phase.$table.table_info.data" )
		or die "Couldn't open $phase.$table.table_info.data for reading: $!\n";
	my $line;
	my @data = ();
	while ( defined( $line = <FH> ) ) {
		my @raw_data = split / /, $line;
		push @data, $raw_data[ 1 ];
	}
	close FH;
	`echo "0 0" > $stats_dir/$phase.$table.table_info.data`;
	for ( my $i = 1; $i < scalar( @data ); $i++ ) {
		my $newval = $data[ $i ] - $data[ $i - 1 ];
		`echo "$i $newval" >> $stats_dir/$phase.$table.table_info.data`;
	}
}
