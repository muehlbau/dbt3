#!/bin/sh

if [ $# -lt 1 ]; then
        echo "Usage: ./run_load_test.sh <scale_factor>"
        exit
fi

scale_factor=$1

GTIME="${DBT3_INSTALL_PATH}/dbdriver/utils/gtime"

#***load test
echo "`date`: start load test" 
#get the start time
s_time=`$GTIME`
echo "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('LOAD', timestamp, $s_time)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('LOAD', timestamp, $s_time)"
$DBT3_INSTALL_PATH/scripts/sapdb/build_db.sh > build_db.log
echo "sql_execute update time_statistics set e_time=timestamp where task_name='LOAD' and int_time=$s_time"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistics set e_time=timestamp where task_name='LOAD' and int_time=$s_time"
e_time=`$GTIME`
echo "`date`: load test end" 
let "diff_time=$e_time-$s_time"
echo "elapsed time for load test $diff_time" 
