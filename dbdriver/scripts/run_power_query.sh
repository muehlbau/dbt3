if [ $# -ne 3 ]; then
        echo "Usage: ./run_power_query.sh <scale_factor> <perf_run_number> <dbt3_dir>"
        exit
fi

scale_factor=$1
perf_run_number=$2
dbt3_dir=$3
GTIME="${dbt3_dir}/dbdriver/utils/gtime"

qgen_dir="$dbt3_dir/datagen/dbgen"
run_dir="$dbt3_dir/run"
seed_file="$run_dir/seed"
query_file="$run_dir/power_query"
tmp_query_file="$run_dir/tmp_query.sql"
param_file="$run_dir/power_param"

if [ ! -f $seed_file ];
then
        echo "creating seed file $seed_file, you can change the seed by modifying this file"
	$dbt3_dir/dbdriver/scripts/init_seed.sh > $seed_file
fi

#generate the queries for power test
rm $query_file
cd $qgen_dir
echo "generate queries in $qgen_dir"
./qgen -c -r `cat $seed_file` -p 0 -s $scale_factor -l $param_file> $query_file
cd "$dbt3_dir/dbdriver/utils"
# modify $query_file so that the commands are in one line
./parse_query $query_file $tmp_query_file P $perf_run_number

#run the queries
echo "`date`: start power queries "
s_time=`$GTIME`
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistic (task_name, s_time) values ('PERF${perf_run_number}.POWER.QS', timestamp)"
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt -i $tmp_query_file
dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistic set e_time=timestamp where task_name='PERF${perf_run_number}.POWER.QS'"
e_time=`$GTIME`
echo "`date`: end queries "
let "diff_time=$e_time-$s_time"
echo "elapsed time for power queries $diff_time"
