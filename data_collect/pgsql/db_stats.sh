#!/bin/sh

if [ $# -ne 4 ]; then
	echo "usage: db_stats.sh <database_name> <output_dir> <iterations> <interval>"
	exit
fi

OUTPUT_DIR=$2
ITERATIONS=$3
SAMPLE_LENGTH=$4

COUNTER=0

# put db info into the readme.txt file
psql --version >> $OUTPUT_DIR/readme.txt
echo "the database statistics is taken at $SAMPLE_LENGTH interval and $ITERATIONS count" >> $OUTPUT_DIR/readme.txt
#echo >> $OUTPUT_DIR/readme.txt

# save the database parameters
psql -d $SID -U $PGUSER -c "show all"  > $OUTPUT_DIR/param.out

#record indexes
echo "collect index and key infomation"
psql -d $SID -U $PGUSER -c "select * from pg_stat_user_indexes;" -o $OUTPUT_DIR/indexes.out

mkdir -p $OUTPUT_DIR/db_stat
mkdir -p $OUTPUT_DIR/ipcs

# record data and log devspace space information before the test

# reset monitor tables

date
echo "starting database statistics collection iteration $ITERATIONS"
while [ $COUNTER -lt $ITERATIONS ]; do
	# collent ipcs stats
        ipcs >> $OUTPUT_DIR/ipcs/ipcs${COUNTER}.out

	# check lock statistics
	psql -d $SID -U $PGUSER -c "select relname,pid, mode, granted from pg_locks, pg_class where relfilenode = relation;" -o  $OUTPUT_DIR/db_stat/lockstats${COUNTER}.out
	psql -d $SID -U $PGUSER -c "select * from pg_locks where transaction is not NULL;" -o $OUTPUT_DIR/db_stat/tran_lock${COUNTER}.out

	# read the database activity table
	psql -d $SID -U $PGUSER -c "select * from pg_stat_activity;" -o $OUTPUT_DIR/db_stat/db_activity${COUNTER}.out
	# database load
	psql -d $SID -U $PGUSER -c "select * from pg_stat_database where datname='DBT3';" -o $OUTPUT_DIR/db_stat/db_load${COUNTER}.out
	# table info
	psql -d $SID -U $PGUSER -c "select relid, relname, heap_blks_read, heap_blks_hit, idx_blks_read, idx_blks_hit from pg_statio_user_tables;" -o $OUTPUT_DIR/db_stat/table_info${COUNTER}.out
	psql -d $SID -U $PGUSER -c "select  relid, indexrelid, relname, indexrelname, idx_blks_read, idx_blks_hit from pg_statio_user_indexes;" -o $OUTPUT_DIR/db_stat/index_info${COUNTER}.out
	# scans 
	psql -d $SID -U $PGUSER -c "select * from pg_stat_user_tables;" -o $OUTPUT_DIR/db_stat/table_scan${COUNTER}.out
	psql -d $SID -U $PGUSER -c "select * from pg_stat_user_indexes;" -o $OUTPUT_DIR/db_stat/indexes_scan${COUNTER}.out
	let "COUNTER=$COUNTER+1"
	sleep $SAMPLE_LENGTH
done
