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
	echo "Usage: ./sys_stats.sh <interval> <duration> <result_dir>"
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
if [ -f $RESULTS_PATH/run.sar.data ]; then
	rm $RESULTS_PATH/run.sar.data
fi

echo "start sar"
VERSION=`uname -r | awk -F "." '{print $2}'`
if [ $VERSION -eq 5 ]
then
        # 2.5 kernel use sysstat version 4.1.2 in /usr/local/bin
        export PATH=/usr/local/bin:/usr/bin:$PATH
else
        # 2.4 kernel use sysstat version 4.0.3 in /usr/bin
        export PATH=/usr/bin:/usr/local/bin:$PATH
fi

#get sysstat version
sar -V &> .sar.tmp
sysstat=`cat .sar.tmp |grep version | awk '{print $3}'`
rm .sar.tmp

#sar
echo "start sar version $sysstat"
if [ $sysstat = '4.1.2' ]; then
	sar -u -P ALL -d -B -r -q -W -b -o $RESULTS_PATH/run.sar.data $INTERVAL $COUNT &
else
	sar -u -U ALL -d -B -r -q -W -b -o $RESULTS_PATH/run.sar.data $INTERVAL $COUNT &
fi
	
#iostat
echo "start iostat"
iostat -d $INTERVAL $COUNT >> $RESULTS_PATH/iostat.txt &
# collect vmstat 
echo "start vmstat"
echo "vmstat $INTERVAL $COUNT" > $RESULTS_PATH/vmstat.out
vmstat $INTERVAL $COUNT >> $RESULTS_PATH/vmstat.out &
#sh ./runtop.sh $1 $2 $RESULTS_PATH &

echo "sleep for $RUN_DURATION seconds..."
sleep $RUN_DURATION
echo "sys_stats.sh done"
