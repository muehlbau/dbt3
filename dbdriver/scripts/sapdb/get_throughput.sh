#
# get_throughput.sh: get dbt3 throughput numerical quantity
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
#
#!/bin/sh

if [ $# -ne 3 ]; then
        echo "Usage: ./$0 <perf_run_number> <scale_factor> <num_stream>"
        exit
fi

perf_run_number=$1
scale_factor=$2
number_of_stream=$3

_o=`cat <<EOF | dbmcli -d DBT3 -u dbm,dbm 2>&1
param_getvalue DATE_TIME_FORMAT
quit
EOF`
_test=`echo $_o | grep INTERNAL`
#if DATE_TIME_FORMAT is not INTERANL
if [ "$_test" = "" ]; then
	echo "set date_time_format to INTERNAL"
	_o=`cat <<EOF | dbmcli -d DBT3 -u dbm,dbm 2>&1
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

# get throughput time
echo "get throughput time"
#echo "sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF${perf_run_number}.THRUPUT'"
Ts=`dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute select timediff(e_time, s_time) from time_statistics where task_name='PERF${perf_run_number}.THRUPUT'"|grep -v 'OK' |grep -v 'END' | xargs $DBT3_INSTALL_PATH/dbdriver/scripts/string_to_number.sh `
echo "Throughput takes $Ts seconds"

#calculate throughput numerical quantity
echo "throughput numerical quantity:"
bc -l<<END-OF-INPUT
scale = 6
22*3600*${number_of_stream}*${scale_factor}/$Ts
quit
END-OF-INPUT
