#!/bin/sh

if [ $# -ne 4 ]; then
        echo "Usage: ./run_refresh_stream.sh <scale_factor> <stream_num> <perf_run_number> <dbt3_dir>"
        exit
fi

scale_factor=$1
stream_num=$2
perf_run_num=$3
dbt3_dir=$4
GTIME="$dbt3_dir/dbdriver/utils/gtime"

echo "`date`:=======refresh stream $stream_num========"

s_time_stream=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THRUPUT.RFST${stream_num}', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THRUPUT.RFST${stream_num}', timestamp)"

echo "`date`: start throughput test refresh stream $stream_num rf1"
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF1', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF1', timestamp)"
./run_rf1.sh $scale_factor $dbt3_dir
echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF1'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF1'"
e_time=`$GTIME`
echo "`date`: end throughput test refresh stream $i rf1"
let "diff_time=$e_time-$s_time"
echo "elapsed time for throughput test refresh stream $i rf1 $diff_time"

echo "`date`: start throughput test refresh stream $i rf2"
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF2', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF2', timestamp)"
./run_rf2.sh $dbt3_dir
echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF2'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.RFST${stream_num}.RF2'"
e_time=`$GTIME`
echo "`date`: end throughput test refresh stream $i rf2"
let "diff_time=$e_time-$s_time"
echo "elapsed time for throughput test refresh stream $i rf2 $diff_time"

echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.RFST${stream_num}'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THRUPUT.RFST${stream_num}'"
e_time_stream=`$GTIME`
let "diff_time=$e_time_stream-$s_time_stream"
echo "elapsed time for throughput test refresh stream $i $diff_time"
