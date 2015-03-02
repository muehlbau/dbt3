# analyze_dbmon_dir.sh: parse sapdb monitor output
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
# March 2003

#!/bin/bash

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
