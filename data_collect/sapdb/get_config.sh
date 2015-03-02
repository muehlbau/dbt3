# get_config.sh: get dbt3 run configuration
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
# March 2003

#!/bin/bash

if [ $# -lt 3 ]; then
        echo "usage: $0.sh <scale_factor> <number of stream> <output_dir>"
        exit
fi

scale_factor=$1
num_stream=$2
output_dir=$3

kernel=`uname -r`
sapdb=`dbmcli dbm_version|grep BUILD| awk '{print $4 $5 $6}'`
procps=`vmstat -V|grep version| awk '{print $3}'`
sar -V &> .sar.tmp
sysstat=`cat .sar.tmp |grep version | awk '{print $3}'`
rm .sar.tmp

CPUS=`grep -c '^processor' /proc/cpuinfo`
MHz=`grep 'cpu MHz' /proc/cpuinfo|head -1|awk -F: '{print $2}'`
model=`grep 'model name' /proc/cpuinfo|head -1|awk -F: '{print $2}'`

memory=`grep 'MemTotal' /proc/meminfo | awk -F: '{print $2 $3}'`
data_dev=`dbmcli -d $SID -u dbm,dbm param_extgetall | grep '^DATADEV_00' | wc -l`
sys_dev=`dbmcli -d $SID -u dbm,dbm param_extgetall | grep '^SYSDEV_00' | wc -l`
log_dev=`dbmcli -d $SID -u dbm,dbm param_extgetall | grep '^ARCHIVE_LOG_00' | wc -l`

shmmax_value=`/sbin/sysctl -e -a |grep shmmax|awk '{print $3}'`

echo "kernel: $kernel" > $output_dir/config.txt
echo "sapdb: $sapdb">> $output_dir/config.txt
echo "procps: $procps">> $output_dir/config.txt
echo "sysstat: $sysstat">> $output_dir/config.txt
echo "CPUS: $CPUS">> $output_dir/config.txt
echo "MHz: $MHz">> $output_dir/config.txt
echo "model: $model">> $output_dir/config.txt
echo "memory: $memory">> $output_dir/config.txt
echo "scale_factor: $scale_factor">> $output_dir/config.txt
echo "num_stream: $num_stream">> $output_dir/config.txt
echo "shmmax: $shmmax_value" >> $output_dir/config.txt
echo "data_dev_space: $data_dev data devspaces on $data_dev raw devices " >> $output_dir/config.txt
echo "sys_dev_space: $sys_dev system devspaces on file system" >> $output_dir/config.txt
echo "log_dev_space: $log_dev log devspaces on $log_dev raw devices" >> $output_dir/config.txt
