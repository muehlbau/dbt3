#!/bin/sh

if [ $# -lt 2 ]; then
        echo "Usage: ./run_dbt3.sh <scale_factor> <num_stream> [seed]"
        exit
fi

scale_factor=$1
num_stream=$2
run_dir="$DBT3_INSTALL_PATH/run"
seed_file="$run_dir/seed"
dbdriver_path="$DBT3_INSTALL_PATH/dbdriver/scripts"
db_path="$DBT3_INSTALL_PATH/scripts/sapdb"

if [ $# -eq 3 ]; then
	echo "running $SID with seed $3"
	echo "$3" > $seed_file
else
	echo "running $SID with default seed"
	echo "`date`: generate seed0" 
	$DBT3_INSTALL_PATH/dbdriver/scripts/init_seed.sh > $seed_file
fi

GTIME="${DBT3_INSTALL_PATH}/dbdriver/utils/gtime"

#get time stamp
s_time_dbt3=`$GTIME`

#***load test
echo "`date +'%Y-%m-%d %H:%M:%S'`: start load test" 
#cd $DBT3_INSTALL_PATH/scripts/sapdb
#get the start time
s_time=`$GTIME`
$db_path/build_db.sh
e_time=`$GTIME`
echo "`date +'%Y-%m-%d %H:%M:%S'`: load test end" 
let "diff_time_load=$e_time-$s_time"
echo "elapsed time for load test $diff_time_load" 

#cd $DBT3_INSTALL_PATH/dbdriver/scripts
i=1
while [ $i -le 1 ]
do
        echo "start performance test $i"
	$dbdriver_path/run_perf_test.sh $scale_factor $i $num_stream
        let "i=$i+1"
done

e_time_dbt3=`$GTIME`
echo "`date`: dbt3 test end" 
let "diff_time_dbt3=$e_time_dbt3-$s_time_dbt3"
echo "elapsed time for dbt3 test $diff_time_dbt3" 

cd $DBT3_INSTALL_PATH/dbdriver/scripts
echo "execution time"
./q_time.sh
echo "elapsed time for dbt3 test $diff_time_dbt3"
