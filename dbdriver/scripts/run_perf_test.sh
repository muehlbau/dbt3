#!/bin/sh

if [ $# -ne 3 ]; then
        echo "Usage: ./run_perf_test.sh <scale_factor> <perf_run_number> <num_stream>"
        exit
fi

scale_factor=$1
perf_run_num=$2
num_stream=$3
GTIME="${DBT3_INSTALL_PATH}/dbdriver/utils/gtime"
dbdriver_path="$DBT3_INSTALL_PATH/dbdriver/scripts"

echo "`date`:=======performance test $perf_run_num========"
s_time=`$GTIME`
echo "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('PERF${perf_run_num}', timestamp, $s_time)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('PERF${perf_run_num}', timestamp, $s_time)"

#***run power test
$dbdriver_path/run_power_test.sh $scale_factor $perf_run_num

#***run throughput test
$dbdriver_path/run_throughput_test.sh $scale_factor $perf_run_num $num_stream

echo "sql_execute update time_statistics set e_time=timestamp where task_name='PERF${perf_run_num}' and int_time=$s_time"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistics set e_time=timestamp where task_name='PERF${perf_run_num}' and int_time=$s_time"
e_time=`$GTIME`
echo "`date`: end performance test run ${perf_run_num} "
let "diff_time=$e_time-$s_time"
echo "elapsed time for performance test ${perf_run_num} $diff_time"
