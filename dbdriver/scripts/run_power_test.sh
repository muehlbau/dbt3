#!/bin/sh

if [ $# -ne 3 ]; then
        echo "Usage: ./run_power_test.sh <scale_factor> <perf_run_number> <dbt3_dir>"
        exit
fi

scale_factor=$1
perf_run_num=$2
dbt3_dir=$3
qgen_dir="$dbt3_dir/datagen/dbgen"
run_dir="$dbt3_dir/run"
seed_file="$run_dir/seed"
query_file="$run_dir/power_query"
tmp_query_file="$run_dir/tmp_query.sql"
param_file="$run_dir/power_param"

GTIME="${dbt3_dir}/dbdriver/utils/gtime"

echo "`date`: =======power test $perf_run_num========"

echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.POWER', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.POWER', timestamp)"
s_time_power=`$GTIME`

#***run rf1
cd $dbt3_dir/dbdriver/scripts
#get the start time
echo "`date`: start rf1 " 
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.POWER.RF1', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.POWER.RF1', timestamp)"
./run_rf1.sh $scale_factor $dbt3_dir
echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.POWER.RF1'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.POWER.RF1'"
e_time=`$GTIME`
echo "`date`: rf1 end " 
let "diff_time=$e_time-$s_time"
echo "elapsed time for rf1 $diff_time" 

#run the queries
./run_power_query.sh $scale_factor $perf_run_num $dbt3_dir

cd $dbt3_dir/dbdriver/scripts
#get the start time
echo "`date`: start rf2 " 
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.POWER.RF2', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.POWER.RF2', timestamp)"
./run_rf2.sh $dbt3_dir
echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.POWER.RF2'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.POWER.RF2'"
e_time=`$GTIME`
echo "`date`: rf2 end " 
let "diff_time=$e_time-$s_time"
echo "elapsed time for rf2 $diff_time" 

echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.POWER'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.POWER'"

e_time_power=`$GTIME`
echo "`date`: end power test run "
let "diff_time=$e_time_power-$s_time_power"
echo "elapsed time for power test $diff_time"
