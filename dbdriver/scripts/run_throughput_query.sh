if [ $# -ne 4 ]; then
        echo "Usage: ./run_throughput_query.sh <scale_factor> <perf_run_num> <stream_num> <dbt3_dir>"
        exit
fi

scale_factor=$1
perf_run_num=$2
stream_num=$3
dbt3_dir=$4
GTIME="${dbt3_dir}/dbdriver/utils/gtime"

qgen_dir="$dbt3_dir/datagen/dbgen"
run_dir="$dbt3_dir/run"
seed_file="$run_dir/seed"
query_file="$run_dir/throughput_query$stream_num"
tmp_query_file="$run_dir/tmp_throughput_query$stream_num.sql"
param_file="$run_dir/throughput_param$stream_num"

if [ ! -f $seed_file ];
then
        echo "creating seed file $seed_file, you can change the seed by modifying this file"
	$dbt3_dir/dbdriver/scripts/init_seed.sh > $seed_file
fi

seed=`cat $seed_file`

let "seed = $seed + $stream_num"
#generate the queries for power test
rm $query_file
rm $tmp_query_file
cd $qgen_dir
echo "generate queries in $qgen_dir"
./qgen -c -r $seed -p $stream_num -s $scale_factor -l $param_file> $query_file
cd "$dbt3_dir/dbdriver/utils"
# modify $query_file so that the commands are in one line
./parse_query $query_file $tmp_query_file T $perf_run_num $stream_num

#run the queries
echo "`date`: start throughput queries for stream $stream_num "
s_time=`$GTIME`
echo "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THUPUT.QS${stream_num}', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_num}.THUPUT.QS${stream_num}', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt -i $tmp_query_file 
echo "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THUPUT.QS${stream_num}'"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_num}.THUPUT.QS${stream_num}'"
e_time=`$GTIME`
echo "`date`: end queries "
let "diff_time=$e_time-$s_time"
echo "elapsed time for queries $diff_time"
