# sys_stat.sh: get system info using sar, iostat and vmstat
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# March 2003

#!/bin/sh
if [ $# -ne 3 ]; then
	echo "Usage: $0 <interval> <duration> <result_dir>"
	exit
fi

INTERVAL=$1
RUN_DURATION=$2
RESULTS_PATH=$3

#calculate count
let "COUNT=$RUN_DURATION/$INTERVAL"
if [ $COUNT -eq 0 ]
then
	COUNT=1
fi

#get one more count
let "COUNT=$COUNT+1"

##get database statistics
#echo "start db_stats.sh"
#./db_stats.sh $SID $RESULTS_PATH $COUNT $INTERVAL &
#
if [ -f $RESULTS_PATH/power.sar.data ]; then
	rm $RESULTS_PATH/power.sar.data
fi

echo "start sar"
export PATH=/usr/local/bin:$PATH

#get sysstat version
sar -V &> .sar.tmp
sysstat=`cat .sar.tmp |grep version | awk '{print $3}'`
rm .sar.tmp

#sar
echo "start sar version $sysstat"
if [ $sysstat = '4.0.3' ]; then
	sar -u -U ALL -d -B -r -q -W -b -o $RESULTS_PATH/power.sar.data $INTERVAL $COUNT &
else
	sar -u -P ALL -d -B -r -q -W -b -o $RESULTS_PATH/power.sar.data $INTERVAL $COUNT &
fi
	
#ziostat
if [ -f /usr/local/bin/ziostat ]; then
        echo "start ziostat";
        echo "ziostat -x $INTERVAL $COUNT" > $RESULTS_PATH/power.ziostat.txt
        ziostat -x $INTERVAL $COUNT  >> $RESULTS_PATH/power.ziostat.txt &
fi

#iostat
echo "start iostat"
echo "iostat -d $INTERVAL $COUNT" > $RESULTS_PATH/power.iostat.txt
iostat -d $INTERVAL $COUNT >> $RESULTS_PATH/power.iostat.txt &
iostat -x -d $INTERVAL $COUNT >> $RESULTS_PATH/power.iostatx.txt &
# collect vmstat 
echo "start vmstat"
echo "vmstat $INTERVAL $COUNT" > $RESULTS_PATH/power.vmstat.txt
vmstat $INTERVAL $COUNT >> $RESULTS_PATH/power.vmstat.txt &
#sh ./runtop.sh $1 $2 $RESULTS_PATH &

echo "sleep for $RUN_DURATION seconds..."
sleep $RUN_DURATION
echo "sys_stats.sh done"
