#!/bin/sh

if [ $# -ne 3 ]; then
        echo "Usage: ./get_power.sh <perf_run_number> <scale_factor> <num_of_stream>"
        exit
fi

perf_run_number=$1
scale_factor=$2
num_of_stream=$3

echo "call get_power.sh"
#power=`./get_power.sh $perf_run_number $scale_factor`
power=`eval ./get_power.sh $perf_run_number $scale_factor | awk '{if (NF==1) print $1}'` 
echo $power
echo "call get_throughput.sh"
throughput=`eval ./get_throughput.sh  $perf_run_number $scale_factor $num_of_stream | awk '{if (NF==1) print $1}'`
echo $throughput

#calculate the query per hour * SF
echo "the QphH is:"
bc -l<<END-OF-INPUT
sqrt($power*$throughput)
quit
END-OF-INPUT
