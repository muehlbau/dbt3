#!/bin/sh
#
# dbt3_gen_graphs.sh
#
# parse the statistic output and generate graphs for dbt-3 runs
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
# Feb 2003

set -x

if [ $# -lt 2 ]; then
        echo "usage: $0 <input_dir> <output_dir>"
        exit
fi

input_dir=$1
output_dir=$2
CPUS=`grep -c ^processor /proc/cpuinfo`

VERSION=`uname -r | awk -F "." '{print $2}'`
sar -V &> .sar.tmp
sysstat_version=`cat .sar.tmp |grep version | awk '{print $3}'`
rm .sar.tmp

echo "making output dir  $output_dir"
mkdir -p $output_dir

if [ -f $input_dir/load.vmstat.txt ]; then
	echo "parse load vmstat";
	#parse vmstat
	./parse_vmstat.pl -i $input_dir/load.vmstat.txt -o $output_dir/load.vmstat -c "vmstat taken every 60 seconds"

	#generate graphs based on build.vmstat.dat file
	./gr_single_dir.pl -i $output_dir/load.vmstat.dat -o $output_dir/load.vmstat_cpu -t "build vmstat CPU" -b "load.vmstat." -e ".dat" -c 12,13,14,15 -v "percetage" -hl "samples every 60 sec" -y 0:100

	./gr_single_dir.pl -i $output_dir/load.vmstat.dat -o $output_dir/load.vmstat_io -t "load vmstat IO" -b "load.vmstat." -e ".dat" -c 8,9 -v "Block/Sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/load.vmstat.dat -o $output_dir/load.vmstat_memory -t "load vmstat memory" -b "load.vmstat." -e ".dat" -c 2,3,4,5, -v "kblock" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/load.vmstat.dat -o $output_dir/load.vmstat_swap -t "load vmstat swap" -b "load.vmstat." -e ".dat" -c 6,7 -v "kblock/sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/load.vmstat.dat -o $output_dir/load.vmstat_system -t "load vmstat system" -b "load.vmstat." -e ".dat" -c 10,11 -v "per sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/load.vmstat.dat -o $output_dir/load.vmstat_procs -t "load vmstat process" -b "load.vmstat." -e ".dat" -c 0,1 -hl "samples every 60 sec"
fi
	
if [ -f $input_dir/power.vmstat.txt ]; then
	echo "parse power test vmstat";
	#parse vmstat
	./parse_vmstat.pl -i $input_dir/power.vmstat.txt -o $output_dir/power.vmstat -c "vmstat taken every 60 seconds"
	#generate graphs based on run.vmstat.dat file
	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_cpu -t "run vmstat CPU" -b "power.vmstat." -e ".dat" -c 12,13,14,15 -v "percetage" -hl "samples every 60 sec" -y 0:100

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_io -t "power vmstat IO" -b "power.vmstat." -e ".dat" -c 8,9 -v "Block/Sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_memory -t "power vmstat memory" -b "power.vmstat." -e ".dat" -c 2,3,4,5, -v "kblock" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_swap -t "power vmstat swap" -b "run.vmstat." -e ".dat" -c 6,7 -v "kblock/sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_system -t "power vmstat system" -b "power.vmstat." -e ".dat" -c 10,11 -v "per sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_procs -t "power vmstat process" -b "power.vmstat." -e ".dat" -c 0,1 -hl "samples every 60 sec"
fi

if [ -f $input_dir/thruput.vmstat.txt ]; then
	echo "parse thruput test vmstat";
	#parse vmstat
	./parse_vmstat.pl -i $input_dir/thruput.vmstat.txt -o $output_dir/thruput.vmstat -c "vmstat taken every 60 seconds"
	#generate graphs based on run.vmstat.dat file
	./gr_single_dir.pl -i $output_dir/thruput.vmstat.dat -o $output_dir/thruput.vmstat_cpu -t "run vmstat CPU" -b "thruput.vmstat." -e ".dat" -c 12,13,14,15 -v "percetage" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thruput.vmstat.dat -o $output_dir/thruput.vmstat_io -t "thruput vmstat IO" -b "thruput.vmstat." -e ".dat" -c 8,9 -v "Block/Sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thruput.vmstat.dat -o $output_dir/thruput.vmstat_memory -t "thruput vmstat memory" -b "thruput.vmstat." -e ".dat" -c 2,3,4,5, -v "kblock" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thruput.vmstat.dat -o $output_dir/thruput.vmstat_swap -t "thruput vmstat swap" -b "run.vmstat." -e ".dat" -c 6,7 -v "kblock/sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thruput.vmstat.dat -o $output_dir/thruput.vmstat_system -t "thruput vmstat system" -b "thruput.vmstat." -e ".dat" -c 10,11 -v "per sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thruput.vmstat.dat -o $output_dir/thruput.vmstat_procs -t "thruput vmstat process" -b "thruput.vmstat." -e ".dat" -c 0,1 -hl "samples every 60 sec"
fi
	
if [ -f $input_dir/load.iostat.txt ]; then
	echo "parse load iostat";
	./parse_iostat.pl -i $input_dir/load.iostat.txt -d $output_dir/load.iostat -co "iostat -d taken every 60 seconds" -o '-d'
	#generate graphs based on load iostat .dat file
	./gr_single_dir.pl -i "$output_dir/load.iostat.*.dat" -o $output_dir/load.iostat_read_sec -t "load iostat read per second" -b "load.iostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.iostat.*.dat" -o $output_dir/load.iostat_write_sec -t "load iostat write per second" -b "load.iostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.iostat.*.dat" -o $output_dir/load.iostat_tps -t "load iostat tps" -b "load.iostat." -e ".dat" -c 0 -hl "samples every 60 sec"
fi

if [ -f $input_dir/power.iostat.txt ]; then
	echo "parse power iostat";
	./parse_iostat.pl -i $input_dir/power.iostat.txt -d $output_dir/power.iostat -co "iostat -d taken every 60 seconds" -o '-d'
	#generate graphs based on power iostat .dat file
	./gr_single_dir.pl -i "$output_dir/power.iostat.*.dat" -o $output_dir/power.iostat_read_sec -t "power iostat read per second" -b "power.iostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.iostat.*.dat" -o $output_dir/power.iostat_write_sec -t "power iostat write per second" -b "power.iostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.iostat.*.dat" -o $output_dir/power.iostat_tps -t "power iostat tps" -b "power.iostat." -e ".dat" -c 0 -hl "samples every 60 sec"
fi

if [ -f $input_dir/thruput.iostat.txt ]; then
	echo "parse thruput iostat";
	./parse_iostat.pl -i $input_dir/thruput.iostat.txt -d $output_dir/thruput.iostat -co "iostat -d taken every 60 seconds" -o '-d'
	#generate graphs based on thruput iostat .dat file
	./gr_single_dir.pl -i "$output_dir/thruput.iostat.*.dat" -o $output_dir/thruput.iostat_read_sec -t "thruput iostat read per second" -b "thruput.iostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.iostat.*.dat" -o $output_dir/thruput.iostat_write_sec -t "thruput iostat write per second" -b "thruput.iostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.iostat.*.dat" -o $output_dir/thruput.iostat_tps -t "thruput iostat tps" -b "thruput.iostat." -e ".dat" -c 0 -hl "samples every 60 sec"
fi

if [ -f $input_dir/load.ziostat.txt ]; then
	echo "parse load ziostat";
	./parse_ziostat.pl -i $input_dir/load.ziostat.txt -d $output_dir/load.ziostat -co "ziostat -d taken every 60 seconds" -o '-x'
	#generate graphs based on load iostat .dat file
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_read_merge -t "load ziostat read request merged per second" -b "load.ziostat." -e ".dat" -c 0 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_write_merge -t "load ziostat write request merged per second" -b "load.ziostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_read_request -t "load ziostat read request per second" -b "load.ziostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_write_request -t "load ziostat write request per second" -b "load.ziostat." -e ".dat" -c 3 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_kbyte_read -t "load ziostat kbyte read per second" -b "load.ziostat." -e ".dat" -c 4 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_kbyte_write -t "load ziostat kbyte write per second" -b "load.ziostat." -e ".dat" -c 5 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_avg_request_size -t "load ziostat average request size in kbyte" -b "load.ziostat." -e ".dat" -c 6 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_avg_queue_size -t "load ziostat average queued requests" -b "load.ziostat." -e ".dat" -c 7 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_wait_time -t "load ziostat average io wait time" -b "load.ziostat." -e ".dat" -c 8 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_svc_time -t "load ziostat average service time" -b "load.ziostat." -e ".dat" -c 9 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/load.ziostat.*.dat" -o $output_dir/load.ziostat_util -t "load ziostat disk utility" -b "load.ziostat." -e ".dat" -c 10 -hl "samples every 60 sec"
fi

if [ -f $input_dir/power.ziostat.txt ]; then
	echo "parse power ziostat";
	./parse_ziostat.pl -i $input_dir/power.ziostat.txt -d $output_dir/power.ziostat -co "ziostat -d taken every 60 seconds" -o '-x'
	#generate graphs based on power iostat .dat file
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_read_merge -t "power ziostat read request merged per second" -b "power.ziostat." -e ".dat" -c 0 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_write_merge -t "power ziostat write request merged per second" -b "power.ziostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_read_request -t "power ziostat read request per second" -b "power.ziostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_write_request -t "power ziostat write request per second" -b "power.ziostat." -e ".dat" -c 3 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_kbyte_read -t "power ziostat kbyte read per second" -b "power.ziostat." -e ".dat" -c 4 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_kbyte_write -t "power ziostat kbyte write per second" -b "power.ziostat." -e ".dat" -c 5 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_avg_request_size -t "power ziostat average request size in kbyte" -b "power.ziostat." -e ".dat" -c 6 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_avg_queue_size -t "power ziostat average queued requests" -b "power.ziostat." -e ".dat" -c 7 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_wait_time -t "power ziostat average io wait time" -b "power.ziostat." -e ".dat" -c 8 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_svc_time -t "power ziostat average service time" -b "power.ziostat." -e ".dat" -c 9 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/power.ziostat.*.dat" -o $output_dir/power.ziostat_util -t "power ziostat disk utility" -b "power.ziostat." -e ".dat" -c 10 -hl "samples every 60 sec"
fi

if [ -f $input_dir/thruput.ziostat.txt ]; then
	echo "parse thruput ziostat";
	./parse_ziostat.pl -i $input_dir/thruput.ziostat.txt -d $output_dir/thruput.ziostat -co "ziostat -d taken every 60 seconds" -o '-x'
	#generate graphs based on thruput iostat .dat file
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_read_merge -t "thruput ziostat read request merged per second" -b "thruput.ziostat." -e ".dat" -c 0 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_write_merge -t "thruput ziostat write request merged per second" -b "thruput.ziostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_read_request -t "thruput ziostat read request per second" -b "thruput.ziostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_write_request -t "thruput ziostat write request per second" -b "thruput.ziostat." -e ".dat" -c 3 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_kbyte_read -t "thruput ziostat kbyte read per second" -b "thruput.ziostat." -e ".dat" -c 4 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_kbyte_write -t "thruput ziostat kbyte write per second" -b "thruput.ziostat." -e ".dat" -c 5 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_avg_request_size -t "thruput ziostat average request size in kbyte" -b "thruput.ziostat." -e ".dat" -c 6 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_avg_queue_size -t "thruput ziostat average queued requests" -b "thruput.ziostat." -e ".dat" -c 7 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_wait_time -t "thruput ziostat average io wait time" -b "thruput.ziostat." -e ".dat" -c 8 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_svc_time -t "thruput ziostat average service time" -b "thruput.ziostat." -e ".dat" -c 9 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thruput.ziostat.*.dat" -o $output_dir/thruput.ziostat_util -t "thruput ziostat disk utility" -b "thruput.ziostat." -e ".dat" -c 10 -hl "samples every 60 sec"
fi

if [ -f $input_dir/load.sar.data ]; then
	echo "parse load sar -b";
	#parse sar io
	./parse_sar.pl -i $input_dir/load.sar.data -out $output_dir/load.sar_io -c "sar -b taken every 60 seconds" -op '-b'

	echo "parse load sar -r";
	#parse sar memory
	./parse_sar.pl -i $input_dir/load.sar.data -out $output_dir/load.sar_memory -c "sar -r taken every 60 seconds" -op '-r'

	echo "parse load sar -u";
	#parse sar total cpu
	./parse_sar.pl -i $input_dir/load.sar.data -out $output_dir/load.sar_cpu_all -c "sar -u taken every 60 seconds" -op '-u'

	if [ $sysstat_version = '4.0.3' ]; then
		echo "parse load sar -U";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/load.sar.data -out $output_dir/load.sar -c "sar -U taken every 60 seconds" -op '-U' -n $CPUS
	else
		echo "parse load sar -P";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/load.sar.data -out $output_dir/load.sar -c "sar -P taken every 60 seconds" -op '-P' -n $CPUS
	fi

	echo "parse load sar -W";
	#parse sar swapping
	./parse_sar.pl -i $input_dir/load.sar.data -out $output_dir/load.sar_swap -c "sar -W taken every 60 seconds" -op '-W'
	#generate data based on load sar .dat files
	./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_user -t "load sar individual CPU pct_user" -b "load.sar." -e ".dat" -c 0 -hl "samples every 60 sec" -y 0:100
	
	./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_system -t "load sar individual CPU pct_system" -b "load.sar." -e ".dat" -c 2 -hl "samples every 60 sec" -y 0:100
	
	if [ $VERSION -eq 5 ]
	then
		./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_iowait -t "load sar individual CPU pct_iowait" -b "load.sar." -e ".dat" -c 3 -hl "samples every 60 sec" -y 0:100
	
		./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_idle -t "load sar individual CPU pct_idle" -b "load.sar." -e ".dat" -c 4 -hl "samples every 60 sec" -y 0:100
		./gr_single_dir.pl -i "$output_dir/load.sar_cpu_all.dat" -o $output_dir/load.sar_cpu_all -t "load sar CPU" -b "load.sar_cpu_all" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec" -y 0:100
	else
		./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_idle -t "load sar individual CPU pct_idle" -b "load.sar." -e ".dat" -c 3 -hl "samples every 60 sec" -y 0:100
		./gr_single_dir.pl -i "$output_dir/load.sar_cpu_all.dat" -o $output_dir/load.sar_cpu_all -t "load sar CPU" -b "load.sar_cpu_all" -e ".dat" -c 0,1,2,3 -hl "samples every 60 sec" -y 0:100
	fi
	
	#./gr_single_dir.pl -i "$output_dir/load.sar_io.dat" -o $output_dir/load.sar_io -t "sar IO" -b "load.sar_io" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/load.sar_memory.dat" -o $output_dir/load.sar_memory -t "load sar memory" -b "load.sar_memory" -e ".dat" -c 0,1,3,4,5,6,7 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/load.sar_memory.dat" -o $output_dir/load.sar_memory_pct -t "load sar memory percentage" -b "load.sar_memory" -e ".dat" -c 2,8 -hl "samples every 60 sec"
fi

if [ -f $input_dir/power.sar.data ]; then
	echo "parse power sar -b";
	#parse sar io
	./parse_sar.pl -i $input_dir/power.sar.data -out $output_dir/power.sar_io -c "sar -b taken every 60 seconds" -op '-b'

	echo "parse power sar -r";
	#parse sar memory
	./parse_sar.pl -i $input_dir/power.sar.data -out $output_dir/power.sar_memory -c "sar -r taken every 60 seconds" -op '-r'

	echo "parse power sar -u";
	#parse sar total cpu
	./parse_sar.pl -i $input_dir/power.sar.data -out $output_dir/power.sar_cpu_all -c "sar -u taken every 60 seconds" -op '-u'

	if [ $sysstat_version = '4.1.2' ]
	then
		echo "parse power sar -P";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/power.sar.data -out $output_dir/power.sar -c "sar -P taken every 60 seconds" -op '-P' -n $CPUS
	else
		echo "parse power sar -U";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/power.sar.data -out $output_dir/power.sar -c "sar -U taken every 60 seconds" -op '-U' -n $CPUS
	fi

	echo "parse power sar -W";
	#parse sar swapping
	./parse_sar.pl -i $input_dir/power.sar.data -out $output_dir/power.sar_swap -c "sar -W taken every 60 seconds" -op '-W'

	#generate data based on power sar .dat files
	./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_user -t "power sar individual CPU pct_user" -b "power.sar." -e ".dat" -c 0 -hl "samples every 60 sec" -y 0:100
	
	./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_system -t "power sar individual CPU pct_system" -b "power.sar." -e ".dat" -c 2 -hl "samples every 60 sec" -y 0:100
	
	if [ $VERSION -eq 5 ]
	then
		./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_iowait -t "power sar individual CPU pct_iowait" -b "power.sar." -e ".dat" -c 3 -hl "samples every 60 sec" -y 0:100
	
		./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_idle -t "power sar individual CPU pct_idle" -b "power.sar." -e ".dat" -c 4 -hl "samples every 60 sec" -y 0:100
		./gr_single_dir.pl -i "$output_dir/power.sar_cpu_all.dat" -o $output_dir/power.sar_cpu_all -t "power sar CPU" -b "power.sar_cpu_all" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec" -y 0:100
	else
		./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_idle -t "power sar individual CPU pct_idle" -b "power.sar." -e ".dat" -c 3 -hl "samples every 60 sec" -y 0:100
		./gr_single_dir.pl -i "$output_dir/power.sar_cpu_all.dat" -o $output_dir/power.sar_cpu_all -t "power sar CPU" -b "power.sar_cpu_all" -e ".dat" -c 0,1,2,3 -hl "samples every 60 sec" -y 0:100
	fi
	
	./gr_single_dir.pl -i "$output_dir/power.sar_io.dat" -o $output_dir/power.sar_io -t "sar IO" -b "power.sar_io" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/power.sar_memory.dat" -o $output_dir/power.sar_memory -t "power.sar_memory" -b "sar_memory" -e ".dat" -c 0,1,3,4,5,6,7 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/power.sar_memory.dat" -o $output_dir/power.sar_memory_pct -t "power sar memory percentage" -b "power.sar_memory" -e ".dat" -c 2,8 -hl "samples every 60 sec"
fi

if [ -f $input_dir/thruput.sar.data ]; then
	echo "parse thruput sar -b";
	#parse sar io
	./parse_sar.pl -i $input_dir/thruput.sar.data -out $output_dir/thruput.sar_io -c "sar -b taken every 60 seconds" -op '-b'

	echo "parse thruput sar -r";
	#parse sar memory
	./parse_sar.pl -i $input_dir/thruput.sar.data -out $output_dir/thruput.sar_memory -c "sar -r taken every 60 seconds" -op '-r'

	echo "parse thruput sar -u";
	#parse sar total cpu
	./parse_sar.pl -i $input_dir/thruput.sar.data -out $output_dir/thruput.sar_cpu_all -c "sar -u taken every 60 seconds" -op '-u'

	if [ $sysstat_version = '4.1.2' ]
	then
		echo "parse thruput sar -P";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/thruput.sar.data -out $output_dir/thruput.sar -c "sar -P taken every 60 seconds" -op '-P' -n $CPUS
	else
		echo "parse thruput sar -U";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/thruput.sar.data -out $output_dir/thruput.sar -c "sar -U taken every 60 seconds" -op '-U' -n $CPUS
	fi

	echo "parse thruput sar -W";
	#parse sar swapping
	./parse_sar.pl -i $input_dir/thruput.sar.data -out $output_dir/thruput.sar_swap -c "sar -W taken every 60 seconds" -op '-W'

	#generate data based on thruput sar .dat files
	./gr_single_dir.pl -i "$output_dir/thruput.sar.cpu*.dat" -o $output_dir/thruput.sar_cpu_user -t "thruput sar individual CPU pct_user" -b "thruput.sar." -e ".dat" -c 0 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/thruput.sar.cpu*.dat" -o $output_dir/thruput.sar_cpu_system -t "thruput sar individual CPU pct_system" -b "thruput.sar." -e ".dat" -c 2 -hl "samples every 60 sec"
	
	if [ $VERSION -eq 5 ]
	then
		./gr_single_dir.pl -i "$output_dir/thruput.sar.cpu*.dat" -o $output_dir/thruput.sar_cpu_iowait -t "thruput sar individual CPU pct_iowait" -b "thruput.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
	
		./gr_single_dir.pl -i "$output_dir/thruput.sar.cpu*.dat" -o $output_dir/thruput.sar_cpu_idle -t "thruput sar individual CPU pct_idle" -b "thruput.sar." -e ".dat" -c 4 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/thruput.sar_cpu_all.dat" -o $output_dir/thruput.sar_cpu_all -t "thruput sar CPU" -b "thruput.sar_cpu_all" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	else
		./gr_single_dir.pl -i "$output_dir/thruput.sar.cpu*.dat" -o $output_dir/thruput.sar_cpu_idle -t "thruput sar individual CPU pct_idle" -b "thruput.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/thruput.sar_cpu_all.dat" -o $output_dir/thruput.sar_cpu_all -t "thruput sar CPU" -b "thruput.sar_cpu_all" -e ".dat" -c 0,1,2,3 -hl "samples every 60 sec"
	fi
	
	./gr_single_dir.pl -i "$output_dir/thruput.sar_io.dat" -o $output_dir/thruput.sar_io -t "sar IO" -b "thruput.sar_io" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/thruput.sar_memory.dat" -o $output_dir/thruput.sar_memory -t "thruput.sar_memory" -b "sar_memory" -e ".dat" -c 0,1,3,4,5,6,7 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/thruput.sar_memory.dat" -o $output_dir/thruput.sar_memory_pct -t "thruput sar memory percentage" -b "thruput.sar_memory" -e ".dat" -c 2,8 -hl "samples every 60 sec"
fi

#parse ips.csv output
if [ -f $input_dir/ips.csv ]; then
	echo "parse ips.csv";
	#parse vips.csv
	./parse_ips.pl -i $input_dir/ips.csv -o $output_dir/ips.dat -c "Transaction Per Second"

	#generate graphs based on build.vmstat.dat file
	./gr_single_dir.pl -i $output_dir/ips.dat -o $output_dir/ips -t "Transaction Per Second" -b "" -e "dat" -c 0,1
fi
