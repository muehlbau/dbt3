#!/bin/sh

if [ $# -ne 4 ]; then
        echo "Usage: ./run_perf_test.sh <scale_factor> <perf_run_number> <run_id> <dbt3_dir>"
        exit
fi

scale_factor=$1
perf_run_number=$2
run_id=$3
dbt3_dir=$4

qgen_dir="$dbt3_dir/datagen/dbgen"
run_dir="$dbt3_dir/run"
seed_file="$run_dir/seed"
output_dir="$run_dir/output/$run_id"
query_file="$run_dir/power_query"
param_file="$run_dir/power_param"

#generate the queries for power test
cd $qgen_dir
./qgen -c -r `cat $seed_file` -p 0 -s $scale_factor -l $param_file > $query_file
