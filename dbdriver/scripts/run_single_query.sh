if [ $# -ne 2 ]; then
        echo "Usage: ./run_single_query.sh <scale_factor> <query_name>"
        exit
fi

scale_factor=$1
query_name=$2
GTIME="${DBT3_INSTALL_PATH}/dbdriver/utils/gtime"

qgen_dir="$DBT3_INSTALL_PATH/datagen/dbgen"
run_dir="$DBT3_INSTALL_PATH/run"
seed_file="$run_dir/seed"
query_file="$run_dir/$query_name.sql"
tmp_query_file="$run_dir/tmp_$query_name.sql"
param_file="$run_dir/$query_name.param"

if [ ! -f $seed_file ];
then
        echo "creating seed file $seed_file, you can change the seed by modifying this file"
	./init_seed.sh > $seed_file
fi

#generate the queries for power test
rm $query_file
cd $qgen_dir
echo "generate queries in $qgen_dir"
./qgen -c -r `cat $seed_file` -s $scale_factor -l $param_file $query_name> $query_file
cd "$DBT3_INSTALL_PATH/dbdriver/utils"
# modify $query_file so that the commands are in one line
./parse_query $query_file $tmp_query_file S

#run the queries
echo "`date`: start queries "
s_time=`$GTIME`
echo "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('QUERY$query_name', timestamp, $s_time)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute insert into time_statistics (task_name, s_time, int_time) values ('QUERY$query_name', timestamp, $s_time)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt -i $tmp_query_file
echo "sql_execute update time_statistics set e_time=timestamp where task_name='QUERY$query_name and int_time=$s_time'"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute update time_statistics set e_time=timestamp where task_name='QUERY$query_name' and int_time=$s_time"
e_time=`$GTIME`
echo "`date`: end queries "
let "diff_time=$e_time-$s_time"
echo "elapsed time for queries $diff_time"
