#!/bin/sh

if [ $# -ne 3 ]; then
	echo "usage: db_stats.sh <database_name> <output_dir> <phase>"
	exit 1
fi

OUTPUT_DIR=$2
PHASE=$3

SAMPLE_LENGTH=60

# put db info into the readme.txt file
psql --version >> $OUTPUT_DIR/readme.txt
echo "Database statistics taken at $SAMPLE_LENGTH second intervals, $ITERATIONS times." >> $OUTPUT_DIR/readme.txt

# save the database parameters
psql -d $SID -c "SHOW ALL"  > $OUTPUT_DIR/$PHASE.param.out

# record indexes
psql -d $SID -c "SELECT * FROM pg_stat_user_indexes;" -o $OUTPUT_DIR/$PHASE.indexes.out

mkdir -p $OUTPUT_DIR/db_stat
mkdir -p $OUTPUT_DIR/ipcs

while [ 1 ]; do
	# collent ipcs stats
        ipcs >> $OUTPUT_DIR/ipcs/$PHASE.ipcs.out

	# Column stats for Tom Lane.
	psql -d $SID -c "SELECT * FROM pg_stats WHERE attname = 'p_partkey';" >> $OUTPUT_DIR/db_stat/$PHASE.p_partkey.out
	psql -d $SID -c "SELECT * FROM pg_stats WHERE attname = 'l_partkey';" >> $OUTPUT_DIR/db_stat/$PHASE.l_partkey.out
	psql -d $SID -c "SELECT * FROM pg_stats WHERE attname = 'ps_suppkey';" >> $OUTPUT_DIR/db_stat/$PHASE.ps_suppkey.out
	psql -d $SID -c "SELECT * FROM pg_stats WHERE attname = 'l_suppkey';" >> $OUTPUT_DIR/db_stat/$PHASE.l_suppkey.out

	# check lock statistics
	psql -d $SID -c "SELECT relname,pid, mode, granted FROM pg_locks, pg_class WHERE relfilenode = relation;" >> $OUTPUT_DIR/db_stat/$PHASE.lockstats.out
	psql -d $SID -c "SELECT * FROM pg_locks WHERE transaction IS NOT NULL;" >> $OUTPUT_DIR/db_stat/$PHASE.tran_lock.out

	# read the database activity table
	psql -d $SID -c "SELECT * FROM pg_stat_activity;" >> $OUTPUT_DIR/db_stat/$PHASE.db_activity.out
	# table info
	psql -d $SID -c "SELECT relid, relname, heap_blks_read, heap_blks_hit, idx_blks_read, idx_blks_hit FROM pg_statio_user_tables;" >> $OUTPUT_DIR/db_stat/$PHASE.table_info.out
	psql -d $SID -c "SELECT relid, indexrelid, relname, indexrelname, idx_blks_read, idx_blks_hit FROM pg_statio_user_indexes;" >> $OUTPUT_DIR/db_stat/$PHASE.index_info.out
	# scans 
	psql -d $SID -c "SELECT * FROM pg_stat_user_tables;" >> $OUTPUT_DIR/db_stat/$PHASE.table_scan.out
	psql -d $SID -c "SELECT * FROM pg_stat_user_indexes;" >> $OUTPUT_DIR/db_stat/$PHASE.indexes_scan.out
	sleep $SAMPLE_LENGTH
done
