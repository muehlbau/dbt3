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

#parse vmstat
./parse_vmstat.pl -i $input_dir/vmstat.out -o $output_dir/vmstat -c "vmstat taken every 60 seconds" -v 3.1.5

#generate graphs based on vmstat .dat file
./gr_OneFileSomeData.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_cpu -t "vmstat CPU" -v "%" -hl "samples every 60 sec" -c 12,13,14,15,

./gr_OneFileSomeData.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_io -t "vmstat I/O" -v "Block/Sec" -hl "samples every 60 sec" -c 8,9,

./gr_OneFileSomeData.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_memory -t "vmstat memory" -v "kblock" -hl "samples every 60 sec" -c 2,3,4,5,

./gr_OneFileSomeData.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_swap -t "vmstat swap" -v "kblock/sec" -hl "samples every 60 sec" -c 6,7,

./gr_OneFileSomeData.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_system -t "vmstat system" -v "per sec" -hl "samples every 60 sec" -c 10,11,

./gr_OneFileSomeData.pl -i $output_dir/vmstat.dat -o $output_dir/vmstat_procs -t "vmstat process" -hl "samples every 60 sec" -c 0,1,

#parse iostat
./parse_iostat.pl -i $input_dir/iostat.txt -o $output_dir/iostat 

#generate graphs based on iostat .dat file
./gr_ManyFilesSomeData.pl -i "$output_dir/*.read.dat" -o $output_dir/iostat_read -c 0, -b "iostat." -e ".read.dat"
./gr_ManyFilesSomeData.pl -i "$output_dir/*.write.dat" -o $output_dir/iostat_write -c 0, -b "iostat." -e ".write.dat"

#parse sar file
./parsedata.pl -f ./dbt3.sar.config -s sarb -v 4.1.1
./parsedata.pl -f ./dbt3.sar.config -s sarB -v 4.1.1
./parsedata.pl -f ./dbt3.sar.config -s tsaru -v 4.1.1
./parsedata.pl -f ./dbt3.sar.config -s sarr -v 4.1.1
./parsedata.pl -f ./dbt3.sar.config -s sarW -v 4.1.1
./parsedata.pl -f ./dbt3.sar.config -s Usar -v 4.1.1

#generate data based on sar .dat files
./gr_ManyFilesSomeData.pl -i "$output_dir/sar_cpu*.dat" -o $output_dir/sar_cpu -t "sar individual CPU " -v "%" -hl "sample every 60 second" -c 0,

./gr_OneFileAllData.pl -i $output_dir/sar_io.dat -o $output_dir/sar_io -t "sar IO all" -v "%" -hl "sample every 60 second" 

./gr_OneFileAllData.pl -i $output_dir/sar_tcpu_all.dat -o $output_dir/sar_cpu_all -t "sar CPU all" -hl "sample every 60 second" 

./gr_OneFileSomeData.pl -i $output_dir/sar_memory.dat -o $output_dir/sar_memory -t "sar memory KB" -v "kbmem" -hl "sample every 60 second" -c 0,1,3,4,5,6,7,

./gr_OneFileSomeData.pl -i $output_dir/sar_memory.dat -o $output_dir/sar_memory_pct -t "sar memory percentage" -v "%" -hl "sample every 60 second" -c 2,8,

#parse x_cons output
$analyzetool_path/parse_xcons_io.pl -i "$input_dir/db_stat/x_cons*.out" -o $output_dir -p $input_dir/param.out 

$analyzetool_path/parse_xcons_process.pl -i "$input_dir/db_stat/x_cons*.out" -o $output_dir

./gr_ManyFilesSomeData.pl -i "$output_dir/xcons_dataio*.dat" -o $output_dir/xcons_dataread -c 1, -b "dataio" -e ".dat"

./gr_ManyFilesSomeData.pl -i "$output_dir/xcons_dataio*.dat" -o $output_dir/xcons_datawrite -c 2,  -b "dataio" -e ".dat"

./gr_ManyFilesSomeData.pl -i "$output_dir/xcons_dataio*.dat" -o $output_dir/xcons_datatotal -c 3, -b "dataio" -e ".dat"

./gr_ManyFilesSomeData.pl -i "$output_dir/xcons_logio*.dat" -o $output_dir/xcons_logwrite -c 3,
