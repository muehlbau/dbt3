#!/bin/sh

if [ $# -lt 2 ]; then
        echo "Usage: ./run_dbt3.sh <scale_factor> <num_stream> [seed]"
        exit
fi

scale_factor=$1
num_stream=$2
run_dir="$DBT3_INSTALL_PATH/run"
seed_file="$run_dir/seed"

if [ $# -eq 3 ]; then
	echo "running $SID with seed $3"
	echo "$3" > $seed_file
else
	echo "running $SID with default seed"
	echo "`date`: generate seed0" 
	$DBT3_INSTALL_PATH/dbdriver/scripts/init_seed.sh > $seed_file
fi

GTIME="${DBT3_INSTALL_PATH}/dbdriver/utils/gtime"

#clean time_statistics table
echo "sql_execute delete from time_statistics"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute delete from time_statistics"

#get time stamp
s_time_dbt3=`$GTIME`
echo "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('DBT3', timestamp, $s_time_dbt3)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('DBT3', timestamp, $s_time_dbt3)"

#***load test
echo "`date`: start load test" 
cd $DBT3_INSTALL_PATH/scripts/sapdb
#get the start time
s_time=`$GTIME`
echo "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('LOAD', timestamp, $s_time)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('LOAD', timestamp, $s_time)"
./build_db.sh
echo "sql_execute update time_statistics set e_time=timestamp where task_name='LOAD' and int_time=$s_time"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistics set e_time=timestamp where task_name='LOAD' and int_time=$s_time"
e_time=`$GTIME`
echo "`date`: load test end" 
let "diff_time=$e_time-$s_time"
echo "elapsed time for load test $diff_time" 

cd $DBT3_INSTALL_PATH/dbdriver/scripts
i=1
while [ $i -le 2 ]
do
        echo "start performance test $i"
	./run_perf_test.sh $scale_factor $i $num_stream
        let "i=$i+1"
done

echo "sql_execute update time_statistics set e_time=timestamp where task_name='DBT3' and int_time=$s_time_dbt3"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistics set e_time=timestamp where task_name='DBT3' and int_time=$s_time_dbt3"
e_time_dbt3=`$GTIME`
echo "`date`: dbt3 test end" 
let "diff_time=$e_time_dbt3-$s_time_dbt3"
echo "elapsed time for dbt3 test $diff_time" 
