#!/bin/sh

if [ $# -lt 2 ]; then
        echo "Usage: ./run_load_test.sh <scale_factor> <dbt3_dir>"
        exit
fi

scale_factor=$1
dbt3_dir=$2

GTIME="${dbt3_dir}/dbdriver/utils/gtime"

#***load test
echo "`date`: start load test" 
#get the start time
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('LOAD', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('LOAD', timestamp)"
$dbt3_dir/scripts/sapdb/build_db.sh > build_db.log
echo "sql_execute update time_statistic set e_time=timestamp where task_name='LOAD'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='LOAD'"
e_time=`$GTIME`
echo "`date`: load test end" 
let "diff_time=$e_time-$s_time"
echo "elapsed time for load test $diff_time" 
