#!/bin/sh

# query_stats.sh: run specified query and collect database and system statistics
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# 20 Jan 2003

if [ $# -lt 2 ]; then
        echo "usage: query_stats.sh <query_num> <scale_factor> [-d duration -i interval]"
        exit
fi

query_num=$1
scale_factor=$2
CPUS=`grep -c processor /proc/cpuinfo`

#these number are taken from power run, if we restart the database
#the number shoule be higher
qtime[0]=734
qtime[1]=108
qtime[2]=306
qtime[3]=108
qtime[4]=252
qtime[5]=667
qtime[6]=598
qtime[7]=323
qtime[8]=1017
qtime[9]=209
qtime[10]=77
qtime[11]=683
qtime[12]=345
qtime[13]=196
qtime[14]=346
qtime[15]=69
qtime[16]=43
qtime[17]=628
qtime[18]=194
qtime[19]=254
qtime[20]=706
qtime[21]=113

duration=0
interval=0
shift 2
# process the command line parameters
while getopts ":d:i:" opt; do
	case $opt in
		d) duration=$OPTARG
				;;
		i) interval=$OPTARG
				;;
		?) echo "Usage: $0 <query_num> <scale_factor> [-d duration -i interval]"
			exit ;;
		esac
done

#if not specified, then use default value
if [ $interval -eq 0 ] 
then 
	interval=60
fi

if [ $duration -eq 0 ] 
then 
	duration=${qtime[$query_num-1]}
fi

#if interval is larger than duration, then reduce interval by half
while [ $interval -gt $duration ]
do
	let "interval = $interval/2"
done
echo "query_num: $query_num interval: $interval duration: $duration"

_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
param_getvalue DATE_TIME_FORMAT
quit
EOF`
_test=`echo $_o | grep ISO`
#if DATE_TIME_FORMAT is not INTERANL
if [ "$_test" = "" ]; then
        echo "set date_time_format to ISO"
        _o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
        param_startsession
        param_put DATE_TIME_FORMAT ISO
        param_checkall
        param_commitsession
        quit
        EOF`
        _test=`echo $_o | grep OK`
        if [ "$_test" = "" ]; then
                 echo "set parameters failed: $_o"
                exit 1
        fi
fi

sapdb_script_path=$DBT3_INSTALL_PATH/scripts/sapdb
dbdriver_path=$DBT3_INSTALL_PATH/dbdriver/scripts

#make output directory
output_dir=q$query_num
mkdir -p $output_dir

# restart the database
echo "stopping the database"
$sapdb_script_path/stop_db.sh
echo "starting the database"
$sapdb_script_path/start_db.sh

#get execution plan
#can not get execution plan for 15
if [ $query_num -eq 15 ]
then
	./get_exeplan_${query_num}.sh > ${output_dir}/plan${query_num}.out
fi
#get meminfo
cat /proc/meminfo > $output_dir/meminfo0.out
sleep 2

#start sys_stats.sh
./sys_stats.sh $interval $duration $CPUS $output_dir &

#execute the query
echo "$dbdriver_path/run_single_query.sh $scale_factor $query_num"
$dbdriver_path/run_single_query.sh $scale_factor $query_num

#get meminfo
cat /proc/meminfo > $output_dir/meminfo1.out
