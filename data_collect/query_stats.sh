#!/bin/sh

if [ $# -lt 1 ]; then
        echo "usage: query_stats.sh <scale_factor>"
        exit
fi

scale_factor=$1
i=1
while [ $i -le 22 ]
do
	./single_query_stats.sh $i $scale_factor
	let "i=$i+1"
done
