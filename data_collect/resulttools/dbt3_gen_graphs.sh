#!/bin/sh

# dbt3_gen_graphs.sh: parse the statistic output and generate graphs for dbt-3 runs
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
# Feb 2003

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
	./gr_single_dir.pl -i $output_dir/load.vmstat.dat -o $output_dir/load.vmstat_cpu -t "build vmstat CPU" -b "load.vmstat." -e ".dat" -c 12,13,14,15 -v "percetage" -hl "samples every 60 sec"

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
	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_cpu -t "run vmstat CPU" -b "power.vmstat." -e ".dat" -c 12,13,14,15 -v "percetage" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_io -t "power vmstat IO" -b "power.vmstat." -e ".dat" -c 8,9 -v "Block/Sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_memory -t "power vmstat memory" -b "power.vmstat." -e ".dat" -c 2,3,4,5, -v "kblock" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_swap -t "power vmstat swap" -b "run.vmstat." -e ".dat" -c 6,7 -v "kblock/sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_system -t "power vmstat system" -b "power.vmstat." -e ".dat" -c 10,11 -v "per sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/power.vmstat.dat -o $output_dir/power.vmstat_procs -t "power vmstat process" -b "power.vmstat." -e ".dat" -c 0,1 -hl "samples every 60 sec"
fi

if [ -f $input_dir/thuput.vmstat.txt ]; then
	echo "parse thuput test vmstat";
	#parse vmstat
	./parse_vmstat.pl -i $input_dir/thuput.vmstat.txt -o $output_dir/thuput.vmstat -c "vmstat taken every 60 seconds"
	#generate graphs based on run.vmstat.dat file
	./gr_single_dir.pl -i $output_dir/thuput.vmstat.dat -o $output_dir/thuput.vmstat_cpu -t "run vmstat CPU" -b "thuput.vmstat." -e ".dat" -c 12,13,14,15 -v "percetage" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thuput.vmstat.dat -o $output_dir/thuput.vmstat_io -t "thuput vmstat IO" -b "thuput.vmstat." -e ".dat" -c 8,9 -v "Block/Sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thuput.vmstat.dat -o $output_dir/thuput.vmstat_memory -t "thuput vmstat memory" -b "thuput.vmstat." -e ".dat" -c 2,3,4,5, -v "kblock" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thuput.vmstat.dat -o $output_dir/thuput.vmstat_swap -t "thuput vmstat swap" -b "run.vmstat." -e ".dat" -c 6,7 -v "kblock/sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thuput.vmstat.dat -o $output_dir/thuput.vmstat_system -t "thuput vmstat system" -b "thuput.vmstat." -e ".dat" -c 10,11 -v "per sec" -hl "samples every 60 sec"

	./gr_single_dir.pl -i $output_dir/thuput.vmstat.dat -o $output_dir/thuput.vmstat_procs -t "thuput vmstat process" -b "thuput.vmstat." -e ".dat" -c 0,1 -hl "samples every 60 sec"
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

if [ -f $input_dir/thuput.iostat.txt ]; then
	echo "parse thuput iostat";
	./parse_iostat.pl -i $input_dir/thuput.iostat.txt -d $output_dir/thuput.iostat -co "iostat -d taken every 60 seconds" -o '-d'
	#generate graphs based on thuput iostat .dat file
	./gr_single_dir.pl -i "$output_dir/thuput.iostat.*.dat" -o $output_dir/thuput.iostat_read_sec -t "thuput iostat read per second" -b "thuput.iostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.iostat.*.dat" -o $output_dir/thuput.iostat_write_sec -t "thuput iostat write per second" -b "thuput.iostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.iostat.*.dat" -o $output_dir/thuput.iostat_tps -t "thuput iostat tps" -b "thuput.iostat." -e ".dat" -c 0 -hl "samples every 60 sec"
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

if [ -f $input_dir/thuput.ziostat.txt ]; then
	echo "parse thuput ziostat";
	./parse_ziostat.pl -i $input_dir/thuput.ziostat.txt -d $output_dir/thuput.ziostat -co "ziostat -d taken every 60 seconds" -o '-x'
	#generate graphs based on thuput iostat .dat file
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_read_merge -t "thuput ziostat read request merged per second" -b "thuput.ziostat." -e ".dat" -c 0 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_write_merge -t "thuput ziostat write request merged per second" -b "thuput.ziostat." -e ".dat" -c 1 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_read_request -t "thuput ziostat read request per second" -b "thuput.ziostat." -e ".dat" -c 2 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_write_request -t "thuput ziostat write request per second" -b "thuput.ziostat." -e ".dat" -c 3 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_kbyte_read -t "thuput ziostat kbyte read per second" -b "thuput.ziostat." -e ".dat" -c 4 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_kbyte_write -t "thuput ziostat kbyte write per second" -b "thuput.ziostat." -e ".dat" -c 5 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_avg_request_size -t "thuput ziostat average request size in kbyte" -b "thuput.ziostat." -e ".dat" -c 6 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_avg_queue_size -t "thuput ziostat average queued requests" -b "thuput.ziostat." -e ".dat" -c 7 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_wait_time -t "thuput ziostat average io wait time" -b "thuput.ziostat." -e ".dat" -c 8 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_svc_time -t "thuput ziostat average service time" -b "thuput.ziostat." -e ".dat" -c 9 -hl "samples every 60 sec"
	./gr_single_dir.pl -i "$output_dir/thuput.ziostat.*.dat" -o $output_dir/thuput.ziostat_util -t "thuput ziostat disk utility" -b "thuput.ziostat." -e ".dat" -c 10 -hl "samples every 60 sec"
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
	./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_user -t "load sar individual CPU pct_user" -b "load.sar." -e ".dat" -c 0 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_system -t "load sar individual CPU pct_system" -b "load.sar." -e ".dat" -c 2 -hl "samples every 60 sec"
	
	if [ $VERSION -eq 5 ]
	then
		./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_iowait -t "load sar individual CPU pct_iowait" -b "load.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
	
		./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_idle -t "load sar individual CPU pct_idle" -b "load.sar." -e ".dat" -c 4 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/load.sar_cpu_all.dat" -o $output_dir/load.sar_cpu_all -t "load sar CPU" -b "load.sar_cpu_all" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	else
		./gr_single_dir.pl -i "$output_dir/load.sar.cpu*.dat" -o $output_dir/load.sar_cpu_idle -t "load sar individual CPU pct_idle" -b "load.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/load.sar_cpu_all.dat" -o $output_dir/load.sar_cpu_all -t "load sar CPU" -b "load.sar_cpu_all" -e ".dat" -c 0,1,2,3 -hl "samples every 60 sec"
	fi
	
	./gr_single_dir.pl -i "$output_dir/load.sar_io.dat" -o $output_dir/load.sar_io -t "sar IO" -b "load.sar_io" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	
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
	./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_user -t "power sar individual CPU pct_user" -b "power.sar." -e ".dat" -c 0 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_system -t "power sar individual CPU pct_system" -b "power.sar." -e ".dat" -c 2 -hl "samples every 60 sec"
	
	if [ $VERSION -eq 5 ]
	then
		./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_iowait -t "power sar individual CPU pct_iowait" -b "power.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
	
		./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_idle -t "power sar individual CPU pct_idle" -b "power.sar." -e ".dat" -c 4 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/power.sar_cpu_all.dat" -o $output_dir/power.sar_cpu_all -t "power sar CPU" -b "power.sar_cpu_all" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	else
		./gr_single_dir.pl -i "$output_dir/power.sar.cpu*.dat" -o $output_dir/power.sar_cpu_idle -t "power sar individual CPU pct_idle" -b "power.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/power.sar_cpu_all.dat" -o $output_dir/power.sar_cpu_all -t "power sar CPU" -b "power.sar_cpu_all" -e ".dat" -c 0,1,2,3 -hl "samples every 60 sec"
	fi
	
	./gr_single_dir.pl -i "$output_dir/power.sar_io.dat" -o $output_dir/power.sar_io -t "sar IO" -b "power.sar_io" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/power.sar_memory.dat" -o $output_dir/power.sar_memory -t "power.sar_memory" -b "sar_memory" -e ".dat" -c 0,1,3,4,5,6,7 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/power.sar_memory.dat" -o $output_dir/power.sar_memory_pct -t "power sar memory percentage" -b "power.sar_memory" -e ".dat" -c 2,8 -hl "samples every 60 sec"
fi

if [ -f $input_dir/thuput.sar.data ]; then
	echo "parse thuput sar -b";
	#parse sar io
	./parse_sar.pl -i $input_dir/thuput.sar.data -out $output_dir/thuput.sar_io -c "sar -b taken every 60 seconds" -op '-b'

	echo "parse thuput sar -r";
	#parse sar memory
	./parse_sar.pl -i $input_dir/thuput.sar.data -out $output_dir/thuput.sar_memory -c "sar -r taken every 60 seconds" -op '-r'

	echo "parse thuput sar -u";
	#parse sar total cpu
	./parse_sar.pl -i $input_dir/thuput.sar.data -out $output_dir/thuput.sar_cpu_all -c "sar -u taken every 60 seconds" -op '-u'

	if [ $sysstat_version = '4.1.2' ]
	then
		echo "parse thuput sar -P";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/thuput.sar.data -out $output_dir/thuput.sar -c "sar -P taken every 60 seconds" -op '-P' -n $CPUS
	else
		echo "parse thuput sar -U";
		#parse sar individual cpu
		./parse_sar.pl -i $input_dir/thuput.sar.data -out $output_dir/thuput.sar -c "sar -U taken every 60 seconds" -op '-U' -n $CPUS
	fi

	echo "parse thuput sar -W";
	#parse sar swapping
	./parse_sar.pl -i $input_dir/thuput.sar.data -out $output_dir/thuput.sar_swap -c "sar -W taken every 60 seconds" -op '-W'

	#generate data based on thuput sar .dat files
	./gr_single_dir.pl -i "$output_dir/thuput.sar.cpu*.dat" -o $output_dir/thuput.sar_cpu_user -t "thuput sar individual CPU pct_user" -b "thuput.sar." -e ".dat" -c 0 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/thuput.sar.cpu*.dat" -o $output_dir/thuput.sar_cpu_system -t "thuput sar individual CPU pct_system" -b "thuput.sar." -e ".dat" -c 2 -hl "samples every 60 sec"
	
	if [ $VERSION -eq 5 ]
	then
		./gr_single_dir.pl -i "$output_dir/thuput.sar.cpu*.dat" -o $output_dir/thuput.sar_cpu_iowait -t "thuput sar individual CPU pct_iowait" -b "thuput.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
	
		./gr_single_dir.pl -i "$output_dir/thuput.sar.cpu*.dat" -o $output_dir/thuput.sar_cpu_idle -t "thuput sar individual CPU pct_idle" -b "thuput.sar." -e ".dat" -c 4 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/thuput.sar_cpu_all.dat" -o $output_dir/thuput.sar_cpu_all -t "thuput sar CPU" -b "thuput.sar_cpu_all" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	else
		./gr_single_dir.pl -i "$output_dir/thuput.sar.cpu*.dat" -o $output_dir/thuput.sar_cpu_idle -t "thuput sar individual CPU pct_idle" -b "thuput.sar." -e ".dat" -c 3 -hl "samples every 60 sec"
		./gr_single_dir.pl -i "$output_dir/thuput.sar_cpu_all.dat" -o $output_dir/thuput.sar_cpu_all -t "thuput sar CPU" -b "thuput.sar_cpu_all" -e ".dat" -c 0,1,2,3 -hl "samples every 60 sec"
	fi
	
	./gr_single_dir.pl -i "$output_dir/thuput.sar_io.dat" -o $output_dir/thuput.sar_io -t "sar IO" -b "thuput.sar_io" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/thuput.sar_memory.dat" -o $output_dir/thuput.sar_memory -t "thuput.sar_memory" -b "sar_memory" -e ".dat" -c 0,1,3,4,5,6,7 -hl "samples every 60 sec"
	
	./gr_single_dir.pl -i "$output_dir/thuput.sar_memory.dat" -o $output_dir/thuput.sar_memory_pct -t "thuput sar memory percentage" -b "thuput.sar_memory" -e ".dat" -c 2,8 -hl "samples every 60 sec"
fi

#parse ips.csv output
if [ -f $input_dir/ips.csv ]; then
	echo "parse ips.csv";
	#parse vips.csv
	./parse_ips.pl -i $input_dir/ips.csv -o $output_dir/ips.dat -c "Transaction Per Second"

	#generate graphs based on build.vmstat.dat file
	./gr_single_dir.pl -i $output_dir/ips.dat -o $output_dir/ips -t "Transaction Per Second" -b "" -e "dat" -c 0,1
fi
