#!/bin/sh

# throughput_test_stats.sh: run throuput test and collect database and system 
# statistics
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# 28 Jan 2003

if [ $# -lt 3 ]; then
        echo "usage: dbt3_stats.sh <scale_factor> <num_stream> <output_dir> [-d duration -i interval]"
        exit
fi

scale_factor=$1
num_stream=$2
output_dir=$3
CPUS=`grep -c '^processor' /proc/cpuinfo`

#estimated dbt3 run time
dbt3_test_time=21607

duration=0
interval=0
shift 3
# process the command line parameters
while getopts ":d:i:" opt; do
	case $opt in
		d) duration=$OPTARG
				;;
		i) interval=$OPTARG
				;;
		?) echo "Usage: $0 <scale_factor> <num_stream> [-d duration -i interval]"
			exit ;;
		esac
done

#if not specified, then use default value
if [ $interval -eq 0 ] 
then 
	interval=60
fi

if [ $duration -eq 0 ] 
then 
	duration=$dbt3_test_time
fi

#if interval is larger than duration, then reduce interval by half
while [ $interval -gt $duration ]
do
	let "interval = $interval/2"
done

sapdb_script_path=$DBT3_INSTALL_PATH/scripts/sapdb
dbdriver_path=$DBT3_INSTALL_PATH/dbdriver/scripts

#make output directory
echo "make output dir"
#output_dir=dbt3_${test_num}
mkdir -p $output_dir

#get meminfo
echo "get meminfo0"
cat /proc/meminfo > $output_dir/meminfo0.out
sleep 2

#start sys_stats.sh
echo "start sys_stats.sh"
./sys_stats.sh $interval $duration $CPUS $output_dir &

#execute the query
echo "run dbt3 test for scale factor $scale_factor $num_stream streams"
$dbdriver_path/run_dbt3.sh $scale_factor $num_stream

#get meminfo
cat /proc/meminfo > $output_dir/meminfo1.out

#copy sar binary to output_dir
mv ./run.sar.data $output_dir

#calculate composite power
$dbdriver_path/get_composite.sh 1 $scale_factor $num_stream 2>&1 > $output_dir/calc_composite.out
