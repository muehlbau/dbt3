#!/bin/sh

if [ $# -ne 4 ]; then
        echo "Usage: ./run_throughput_test.sh <scale_factor> <perf_run_number> <dbt3_dir> <num_stream>"
        exit
fi

scale_factor=$1
perf_run_number=$2
dbt3_dir=$3
num_stream=$4
GTIME="${dbt3_dir}/dbdriver/utils/gtime"

echo "`date`:=======throughput test $perf_run_number========"
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THUPUT', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THUPUT', timestamp)"

qgen_dir="$dbt3_dir/datagen/dbgen"
run_dir="$dbt3_dir/run"
seed_file="$run_dir/seed"

#generate the queries for throughput test
#and start the streams
i=1
while [ $i -le $num_stream ] 
do
	echo "start throughput query of stream $i"
	#./run_throughput_query.sh $scale_factor $perf_run_number $i $dbt3_dir > $run_dir/thuput_qs$i 2>&1 &
	let "i=$i+1"
done

#start the refresh stream
cd $dbt3_dir/dbdriver/scripts
i=1
while [ $i -le $num_stream ]
do
        echo "start throughput refresh stream stream $i"
	./run_refresh_stream.sh $scale_factor $i $perf_run_number $dbt3_dir > ${run_dir}/refresh_stream$i
        let "i=$i+1"
done

wait
echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THUPUT'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THUPUT'"
e_time=`$GTIME`
echo "`date`: end throughput test run "
let "diff_time=$e_time-$s_time"
echo "elapsed time for throughput test $diff_time"
