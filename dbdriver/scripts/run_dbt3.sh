#!/bin/sh

if [ $# -ne 1 ]; then
        echo "Usage: ./run_dbt3.sh <scale_factor>"
        exit
fi

scale_factor=$1
dbt3_dir="/home/jenny/src/dbt3"
run_dir="$dbt3_dir/run"

run_id_file="$run_dir/run_id"
echo "run_id_file $run_id_file"

if [ ! -f $run_id_file ];
then
	echo "creating file $run_id_file"
	echo "0" > ${run_id_file}
fi

run_id=`cat $run_id_file`
let "run_id=$run_id+1"
echo $run_id>$run_id_file

output_dir="$run_dir/output/$run_id"
if [ ! -d $output_dir ];
then 
	echo "mkdir $output_dir"
	mkdir $output_dir
fi

script_log_file="$output_dir/script_out.log"
seed_file="$run_dir/seed"

echo "start dbt3 run: $run_id">$script_log_file
echo >> $script_log_file

echo "start load test `date`" >> $script_log_file
#get the start time
s_time=`date +%H%M%s`
#$dbt3_dir/scripts/sapdb/build_db.sh > $output_dir/build_db.log
e_time=`date +%H%M%s`
echo "load test end `date`" >> $script_log_file
let "load_time=$e_time-$s_time"
echo "elapsed time for load test $load_time" >> $script_log_file
echo >> $script_log_file

echo "`date` generate seed0" >> $script_log_file
$dbt3_dir/dbdriver/scripts/init_seed.sh > $seed_file

./run_perf_test.sh 1 1 $run_id $dbt3_dir
#echo "start performance test run 1 `date`">> $script_log_file
#run_perf_test.sh $scale_factor 1 $run_id
#echo "end performance test run 1 `date`">> $script_log_file
#echo >> $script_log_file
#echo "start performance test run 2 `date`">> $script_log_file
#run_perf_test.sh $scale_factor 2 $run_id
#echo "end performance test run 2 `date`">> $script_log_file
