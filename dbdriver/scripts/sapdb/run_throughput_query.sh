#
# run_throughput_query.sh: run throughput query stream
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
#
#!/bin/sh
if [ $# -ne 3 ]; then
        echo "Usage: ./run_throughput_query.sh <scale_factor> <perf_run_num> <stream_num>"
        exit
fi

scale_factor=$1
perf_run_num=$2
stream_num=$3
GTIME="${DBT3_INSTALL_PATH}/dbdriver/utils/gtime"

qgen_dir="$DBT3_INSTALL_PATH/datagen/dbgen"
run_dir="$DBT3_INSTALL_PATH/run"
seed_file="$run_dir/seed"
query_file="$run_dir/throughput_query$stream_num"
tmp_query_file="$run_dir/tmp_throughput_query$stream_num.sql"
param_file="$run_dir/throughput_param$stream_num"
parsequery_sapdb_dir="$DBT3_INSTALL_PATH/dbdriver/utils/sapdb"

if [ ! -f $seed_file ];
then
        echo "creating seed file $seed_file, you can change the seed by modifying this file"
	$DBT3_INSTALL_PATH/dbdriver/scripts/init_seed.sh > $seed_file
fi

seed=`cat $seed_file`

let "seed = $seed + $stream_num"
#generate the queries for power test
rm $query_file
rm $tmp_query_file
echo "generate queries in $qgen_dir"
$qgen_dir/qgen -c -r $seed -p $stream_num -s $scale_factor -l $param_file> $query_file
cd "$DBT3_INSTALL_PATH/dbdriver/utils"
# modify $query_file so that the commands are in one line
$parsequery_sapdb_dir/parse_query $query_file $tmp_query_file T $perf_run_num $stream_num

#run the queries
echo "`date`: start throughput queries for stream $stream_num "
s_time=`$GTIME`
echo "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('PERF${perf_run_num}.THRUPUT.QS${stream_num}', timestamp, $s_time)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('PERF${perf_run_num}.THRUPUT.QS${stream_num}', timestamp, $s_time)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt -i $tmp_query_file 
echo "sql_execute update time_statistics set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.QS${stream_num}' and int_time=$s_time"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistics set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.QS${stream_num}' and int_time=$s_time"
e_time=`$GTIME`
echo "`date`: end queries "
let "diff_time=$e_time-$s_time"
echo "elapsed time for queries $diff_time"
