#!/bin/sh

if [ $# -ne 4 ]; then
	echo "usage: db_stats.sh <database_name> <output_dir> <iterations> <sleep>"
	exit
fi

OUTPUT_DIR=$2
ITERATIONS=$3
SAMPLE_LENGTH=$4

COUNTER=0

# put db info into the readme.txt file
/opt/sapdb/depend/bin/dbmcli dbm_version >> $OUTPUT_DIR/readme.txt
echo "the database statistics is taken at $SAMPLE_LENGTH interval and $ITERATIONS count" >> $OUTPUT_DIR/readme.txt
echo >> $OUTPUT_DIR/readme.txt

while [ 1 ]
do
	_o=`/opt/sapdb/depend/bin/dbmcli -d $1 -u dbm,dbm db_state 2>&1`
	_test=`echo $_o | grep -i warm`
	if [ "$_test" = "" ]; then
		echo "wait for database $1 to be on-line"
		sleep 5
	else
		break;
	fi
done

# save the database parameters
/opt/sapdb/depend/bin/dbmcli -d $1 -u dbm,dbm -uSQL dbt,dbt -c param_extgetall | sort > $OUTPUT_DIR/param.out
#read RN < .run_number
#CURRENT_NUM=`expr $RN - 1`
#PREV_NUM=`expr $RN - 2`

#CURRENT_DIR=output/$CURRENT_NUM
#PREV_DIR=output/$PREV_NUM

#echo "Changed SAP DB parameters:" >> $OUTPUT_DIR/readme.txt
#diff -U 0 $CURRENT_DIR/param.out $PREV_DIR/param.out >> $OUTPUT_DIR/readme.txt
#echo >> $OUTPUT_DIR/readme.txt

# record data and log devspace space information before the test
/opt/sapdb/depend/bin/dbmcli -d $1 -u dbm,dbm -uSQL dbt,dbt -c info data > $OUTPUT_DIR/datadev0.txt
/opt/sapdb/depend/bin/dbmcli -d $1 -u dbm,dbm -uSQL dbt,dbt -c info log > $OUTPUT_DIR/logdev0.txt

#record indexes
 /opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from ALL_IND_COLUMNS" > $OUTPUT_DIR/all_ind_columns.out
/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select tablename,columnname, keypos, mode , owner from SHOW_PRIMARY_KEY where owner='DBT' order by tablename, keypos" > $OUTPUT_DIR/primary_keys.out


# reset monitor tables
echo "resetting monitor tables"
/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute monitor init"

# Is the monitor init taking too much time?
date
echo "starting database statistics collection iteration $ITERATIONS"
while [ $COUNTER -lt $ITERATIONS ]; do
	# collent ipcs stats
        ipcs >> $OUTPUT_DIR/ipcs${COUNTER}.out

	# collect x_cons output
	/opt/sapdb/indep_prog/bin/x_cons $1 show all > $OUTPUT_DIR/x_cons${COUNTER}.out
	
	# check lock statistics
	/opt/sapdb/indep_prog/bin/dbmcli -d $1 -u dba,dba -uSQL dbt,dbt sql_execute "SELECT * FROM LOCKSTATISTICS" > $OUTPUT_DIR/lockstats${COUNTER}.out

	# read the monitor tables
	/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from monitor_caches" > $OUTPUT_DIR/m_cache${COUNTER}.out
	/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from monitor_load" > $OUTPUT_DIR/m_load${COUNTER}.out
	/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from monitor_lock" > $OUTPUT_DIR/m_lock${COUNTER}.out
	/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from monitor_log" > $OUTPUT_DIR/m_log${COUNTER}.out
	/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from monitor_pages" > $OUTPUT_DIR/m_pages${COUNTER}.out
	/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from monitor_row" > $OUTPUT_DIR/m_row${COUNTER}.out
	/opt/sapdb/depend/bin/dbmcli -s -d $1 -u dba,dba -uSQL dbt,dbt "sql_execute select * from monitor_trans" > $OUTPUT_DIR/m_trans${COUNTER}.out

	let "COUNTER=$COUNTER+1"
	sleep $SAMPLE_LENGTH
done

/opt/sapdb/depend/bin/dbmcli -d $1 -u dbm,dbm -uSQL dbt,dbt -c info data > $OUTPUT_DIR/datadev1.txt
/opt/sapdb/depend/bin/dbmcli -d $1 -u dbm,dbm -uSQL dbt,dbt -c info log > $OUTPUT_DIR/logdev1.txt
