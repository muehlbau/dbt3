#
# q_time.sh: get task execution time
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
# Author: Jenny Zhang
#
if [ $# -eq 1 ];
then
	psql -d $SID -U $PGUSER -c "select task_name, s_time, e_time, (e_time-s_time) as diff_time from time_statistics;" -o $1/q_time.out
else
	psql -d $SID -U $PGUSER -c "select task_name, s_time, e_time, (e_time-s_time) as diff_time from time_statistics;"
fi


