#!/bin/sh

if [ $# -lt 3 ]; then
        echo "Usage: ./run_dbt3.sh <scale_factor> <num_stream> <dbt3_dir> [seed]"
        exit
fi

scale_factor=$1
num_stream=$2
dbt3_dir=$3
run_dir="$dbt3_dir/run"
seed_file="$run_dir/seed"

if [ $# -eq 4 ]; then
	echo "running dbt3 with seed $4"
	echo "$4" > $seed_file
else
	echo "running dbt3 with default seed"
	echo "`date`: generate seed0" 
	$dbt3_dir/dbdriver/scripts/init_seed.sh > $seed_file
fi

GTIME="${dbt3_dir}/dbdriver/utils/gtime"

#clean time_statistic table
echo "sql_execute delete from time_statistic"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute delete from time_statistic"

#get time stamp
s_time_dbt3=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('DBT3', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('DBT3', timestamp)"

#***load test
echo "`date`: start load test" 
#get the start time
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('LOAD', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('LOAD', timestamp)"
#$dbt3_dir/scripts/build_db/build_db.sh > build_db.log
sleep 3
echo "sql_execute update time_statistic set e_time=timestamp where task_name='LOAD'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='LOAD'"
e_time=`$GTIME`
echo "`date`: load test end" 
let "diff_time=$e_time-$s_time"
echo "elapsed time for load test $diff_time" 

cd $dbt3_dir/dbdriver/scripts
i=1
while [ $i -le 2 ]
do
        echo "start performance test $i"
	./run_perf_test.sh $scale_factor $i $dbt3_dir $num_stream
        let "i=$i+1"
done

echo "sql_execute update time_statistic set e_time=timestamp where task_name='DBT3'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='DBT3'"
e_time_dbt3=`$GTIME`
echo "`date`: dbt3 test end" 
let "diff_time=$e_time_dbt3-$s_time_dbt3"
echo "elapsed time for dbt3 test $diff_time" 
