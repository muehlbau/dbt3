#!/bin/sh

if [ $# -ne 5 ]; then
	echo "usage: db_stats.sh <database_name> <output_dir> <iterations> <interval> <phase>"
	exit 1
fi

OUTPUT_DIR=$2
ITERATIONS=$3
SAMPLE_LENGTH=$4
PHASE=$5

COUNTER=0

# put db info into the readme.txt file
psql --version >> $OUTPUT_DIR/readme.txt
echo "the database statistics is taken at $SAMPLE_LENGTH interval and $ITERATIONS count" >> $OUTPUT_DIR/readme.txt
#echo >> $OUTPUT_DIR/readme.txt

# save the database parameters
psql -d $SID -U $PGUSER -c "show all"  > $OUTPUT_DIR/$PHASE.param.out

#record indexes
echo "collect index and key infomation"
psql -d $SID -U $PGUSER -c "select * from pg_stat_user_indexes;" -o $OUTPUT_DIR/$PHASE.indexes.out

mkdir -p $OUTPUT_DIR/db_stat
mkdir -p $OUTPUT_DIR/ipcs

# record data and log devspace space information before the test

# reset monitor tables

date
echo "starting database statistics collection iteration $ITERATIONS"
while [ $COUNTER -lt $ITERATIONS ]; do
	# collent ipcs stats
        ipcs >> $OUTPUT_DIR/ipcs/$PHASE.ipcs${COUNTER}.out

	# check lock statistics
	psql -d $SID -c "SELECT relname,pid, mode, granted FROM pg_locks, pg_class WHERE relfilenode = relation;" >> $OUTPUT_DIR/db_stat/$PHASE.lockstats.out
	psql -d $SID -c "SELECT * FROM pg_locks WHERE transaction IS NOT NULL;" >> $OUTPUT_DIR/db_stat/$PHASE.tran_lock.out

	# read the database activity table
	psql -d $SID -c "SELECT * FROM pg_stat_activity;" >> $OUTPUT_DIR/db_stat/$PHASE.db_activity.out
	# database load
	psql -d $SID -c "SELECT * FROM pg_stat_database WHERE datname ='dbt2';" >> $OUTPUT_DIR/db_stat/$PHASE.db_load.out
	# table info
	psql -d $SID -c "SELECT relid, relname, heap_blks_read, heap_blks_hit, idx_blks_read, idx_blks_hit FROM pg_statio_user_tables;" >> $OUTPUT_DIR/db_stat/$PHASE.table_info.out
	psql -d $SID -c "SELECT relid, indexrelid, relname, indexrelname, idx_blks_read, idx_blks_hit FROM pg_statio_user_indexes;" >> $OUTPUT_DIR/db_stat/$PHASE.index_info.out
	# scans 
	psql -d $SID -c "SELECT * FROM pg_stat_user_tables;" >> $OUTPUT_DIR/db_stat/$PHASE.table_scan.out
	psql -d $SID -c "SELECT * FROM pg_stat_user_indexes;" >> $OUTPUT_DIR/db_stat/$PHASE.indexes_scan.out
	let "COUNTER=$COUNTER+1"
	sleep $SAMPLE_LENGTH
done
