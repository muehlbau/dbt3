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
analyzetool_path=$DBT3_INSTALL_PATH/data_collect/analyzetools/sapdb

echo "making output dir  $output_dir"
mkdir -p $output_dir

echo "parse vmstat";
#parse vmstat
./parse_vmstat.pl -i $input_dir/vmstat.out -o $output_dir/vmstat -c "vmstat taken every 60 seconds"

echo "parse iostat";
#parse iostat
./parse_iostat.pl -i $input_dir/iostat.txt -d $output_dir/iostat -co "iostat taken every 60 seconds" -o '-d'

echo "parse sar -b";
#parse sar io
./parse_sar.pl -i $input_dir/run.sar.data -out $output_dir/sar_io -c "sar -d taken every 60 seconds" -op '-b'

echo "parse sar -r";
#parse sar memory
./parse_sar.pl -i $input_dir/run.sar.data -out $output_dir/sar_memory -c "sar -r taken every 60 seconds" -op '-r'

echo "parse sar -u";
#parse sar total cpu
./parse_sar.pl -i $input_dir/run.sar.data -out $output_dir/sar_cpu_all -c "sar -u taken every 60 seconds" -op '-u'

echo "parse sar -P";
#parse sar individual cpu
./parse_sar.pl -i $input_dir/run.sar.data -out $output_dir/sar -c "sar -P taken every 60 seconds" -op '-P' -n 8

echo "parse sar -W";
#parse sar swapping
./parse_sar.pl -i $input_dir/run.sar.data -out $output_dir/sar_swap -c "sar -W taken every 60 seconds" -op '-W'

#generate graphs based on vmstat.dat file
./gr_single_dir.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_cpu -t "vmstat CPU" -b "vmstat." -e "dat" -c 12,13,14,15 -v "percetage" -hl "samples every 60 sec"

./gr_single_dir.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_io -t "vmstat IO" -b "vmstat." -e "dat" -c 8,9 -v "Block/Sec" -hl "samples every 60 sec"

./gr_single_dir.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_memory -t "vmstat memory" -b "vmstat." -e "dat" -c 2,3,4,5, -v "kblock" -hl "samples every 60 sec"

./gr_single_dir.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_swap -t "vmstat swap" -b "vmstat." -e "dat" -c 6,7 -v "kblock/sec" -hl "samples every 60 sec"

./gr_single_dir.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_system -t "vmstat system" -b "vmstat." -e "dat" -c 10,11 -v "per sec" -hl "samples every 60 sec"

./gr_single_dir.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_procs -t "vmstat process" -b "vmstat." -e "dat" -c 0,1 -hl "samples every 60 sec"

#generate graphs based on iostat .dat file
./gr_single_dir.pl -i "$output_dir/iostat.*.dat" -o $output_dir/iostat_read_sec -t "iostat read per second" -b "iostat." -e ".dat" -c 1 -hl "samples every 60 sec"
./gr_single_dir.pl -i "$output_dir/iostat.*.dat" -o $output_dir/iostat_write_sec -t "iostat write per second" -b "iostat." -e ".dat" -c 2 -hl "samples every 60 sec"
./gr_single_dir.pl -i "$output_dir/iostat.*.dat" -o $output_dir/iostat_tps -t "iostat tps" -b "iostat." -e ".dat" -c 0 -hl "samples every 60 sec"

#generate data based on sar .dat files
./gr_single_dir.pl -i "$output_dir/sar.cpu*.dat" -o $output_dir/sar_cpu_user -t "sar individual CPU pct_user" -b "sar." -e ".dat" -c 0 -hl "samples every 60 sec"

./gr_single_dir.pl -i "$output_dir/sar.cpu*.dat" -o $output_dir/sar_cpu_system -t "sar individual CPU pct_system" -b "sar." -e ".dat" -c 2 -hl "samples every 60 sec"

./gr_single_dir.pl -i "$output_dir/sar.cpu*.dat" -o $output_dir/sar_cpu_iowait -t "sar individual CPU pct_iowait" -b "sar." -e ".dat" -c 3 -hl "samples every 60 sec"

./gr_single_dir.pl -i "$output_dir/sar.cpu*.dat" -o $output_dir/sar_cpu_idle -t "sar individual CPU pct_idle" -b "sar." -e ".dat" -c 4 -hl "samples every 60 sec"

./gr_single_dir.pl -i "$output_dir/sar_cpu_all.dat" -o $output_dir/sar_cpu_all -t "sar CPU" -b "sar_cpu_all" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"

./gr_single_dir.pl -i "$output_dir/sar_io.dat" -o $output_dir/sar_io -t "sar IO" -b "sar_io" -e ".dat" -c 0,1,2,3,4 -hl "samples every 60 sec"

./gr_single_dir.pl -i "$output_dir/sar_memory.dat" -o $output_dir/sar_memory -t "sar memory" -b "sar_memory" -e ".dat" -c 0,1,3,4,5,6,7 -hl "samples every 60 sec"

./gr_single_dir.pl -i "$output_dir/sar_memory.dat" -o $output_dir/sar_memory_pct -t "sar memory percentage" -b "sar_memory" -e ".dat" -c 2,8 -hl "samples every 60 sec"

#parse x_cons output
$analyzetool_path/parse_xcons_io.pl -i "$input_dir/db_stat/x_cons*.out" -o $output_dir -p $input_dir/param.out 

$analyzetool_path/parse_xcons_process.pl -i "$input_dir/db_stat/x_cons*.out" -o $output_dir

./gr_single_dir.pl -i "$output_dir/xcons_dataio*.dat" -o $output_dir/xcons_dataread -c 1, -b "xcons_dataio" -e ".dat" -t "xcons datadevice read"

./gr_single_dir.pl -i "$output_dir/xcons_dataio*.dat" -o $output_dir/xcons_datawrite -c 2,  -b "xcons_dataio" -e ".dat" -t "xcons datadevice write"

./gr_single_dir.pl -i "$output_dir/xcons_dataio*.dat" -o $output_dir/xcons_datatotal -c 3, -b "xcons_dataio" -e ".dat" -t "xcons datadevice total"

./gr_single_dir.pl -i "$output_dir/xcons_logio*.dat" -o $output_dir/xcons_logwrite -c 3, -b "xcons_logio" -e ".dat" -t "xcons logdevice total io"
