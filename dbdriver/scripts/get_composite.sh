#
# get_composite.sh
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
#
#!/bin/bash

if [ $# -ne 3 ]; then
        echo "Usage: ./get_composite.sh <perf_run_number> <scale_factor> <num_of_stream>"
        exit
fi

perf_run_number=$1
scale_factor=$2
num_of_stream=$3
dbdriver_sapdb_path="$DBT3_INSTALL_PATH/dbdriver/scripts/sapdb"

echo "call get_power.sh"
power=`eval $dbdriver_sapdb_path/get_power.sh $perf_run_number $scale_factor | awk '{if (NF==1) print $1}'` 
echo $power
echo "call get_throughput.sh"
throughput=`eval $dbdriver_sapdb_path/get_throughput.sh  $perf_run_number $scale_factor $num_of_stream | awk '{if (NF==1) print $1}'`
echo $throughput

#calculate the query per hour * SF
echo "the QphH is:"
bc -l<<END-OF-INPUT
scale = 6
sqrt($power*$throughput)
quit
END-OF-INPUT
