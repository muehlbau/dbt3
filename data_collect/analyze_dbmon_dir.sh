#!/bin/sh

if [ $# -ne 2 ]; then
        echo "Usage: ./analyze_dbmon_dir.sh <output_dir> <interval>"
        exit
fi

output_dir=$1
interval=$2

for i in m_cache m_load m_lock m_log m_pages m_row m_trans
do
	./analyze_dbmon_out.sh $output_dir $i $interval > $output_dir/$i.sum
done
