#!/bin/sh

if [ $# -ne 4 ]; then
        echo "Usage: ./run_perf_test.sh <scale_factor> <perf_run_number> <dbt3_dir> <num_stream>"
        exit
fi

scale_factor=$1
perf_run_num=$2
dbt3_dir=$3
num_stream=$4
GTIME="${dbt3_dir}/dbdriver/utils/gtime"

echo "`date`:=======performance test $perf_run_num========"
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}', timestamp)"

#***run power test
./run_power_test.sh $scale_factor $perf_run_num $dbt3_dir

#***run throughput test
./run_throughput_test.sh $scale_factor $perf_run_num $dbt3_dir $num_stream

echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}'"
e_time=`$GTIME`
echo "`date`: end performance test run ${perf_run_num} "
let "diff_time=$e_time-$s_time"
echo "elapsed time for performance test ${perf_run_num} $diff_time"
