#!/bin/sh

if [ $# -ne 2 ]; then
        echo "Usage: ./get_power.sh <perf_run_number> <scale_factor>"
        exit
fi

perf_run_number=$1
scale_factor=$2

_o=`cat <<EOF | dbmcli -d DBT3 -u dbm,dbm 2>&1
param_getvalue DATE_TIME_FORMAT
quit
EOF`
_test=`echo $_o | grep INTERNAL`
#if DATE_TIME_FORMAT is not INTERANL
if [ "$_test" = "" ]; then
	echo "set date_time_format to INTERNAL"
	_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
	db_cold
	param_startsession
	param_put DATE_TIME_FORMAT INTERNAL
	param_checkall
	param_commitsession
	db_stop
	db_start
	db_warm
	quit
	EOF`
	_test=`echo $_o | grep OK`
	if [ "$_test" = "" ]; then
       		 echo "set parameters failed: $_o"
		exit 1
	fi
fi

# get 22 query time for the power test
echo "get 22 query time for the power test"
index=1
while [ "$index" -le 22 ]
do
#echo "sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF${perf_run_number}.POWER.Q${index}'"
power_query[$index]=`dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF${perf_run_number}.POWER.Q${index}'"|grep -v 'OK' |grep -v 'END' | xargs $DBT3_INSTALL_PATH/dbdriver/scripts/string_to_number.sh `
echo " power_query[$index]: ${power_query[$index]}"
let "index = $index + 1"
done

# get 2 refresh function time for the power test
echo "get 2 refresh function time for the power test"
index=1
while [ "$index" -le 2 ]
do
#echo "sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF${perf_run_number}.POWER.RF${index}'"
power_rf[$index]=`dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF${perf_run_number}.POWER.RF${index}'"|grep -v 'OK' |grep -v 'END' | xargs $DBT3_INSTALL_PATH/dbdriver/scripts/string_to_number.sh `
echo "power rf[$index]: ${power_rf[$index]}"
let "index = $index + 1"
done

#calculate the query per hour * SF
echo "the power: "
bc -l<<END-OF-INPUT
3600*${scale_factor}*e(-1/24*(l(${power_query[1]})+l(${power_query[2]})+l(${power_query[3]})+l(${power_query[4]})+l(${power_query[5]})+l(${power_query[6]})+l(${power_query[7]})+l(${power_query[8]})+l(${power_query[9]})+l(${power_query[10]})+l(${power_query[11]})+l(${power_query[12]})+l(${power_query[13]})+l(${power_query[14]})+l(${power_query[15]})+l(${power_query[16]})+l(${power_query[17]})+l(${power_query[18]})+l(${power_query[19]})+l(${power_query[20]})+l(${power_query[21]})+l(${power_query[22]})+l(${power_rf[1]})+l(${power_rf[2]})))
quit
END-OF-INPUT
