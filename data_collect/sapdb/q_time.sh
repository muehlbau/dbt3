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
	dbmcli -d DBT3 -u dbm,dbm -uSQL $DBUSER,$DBUSER -o $1/q_time.out "sql_execute select task_name, s_time, e_time, timediff(e_time,s_time) from time_statistics"
else
	dbmcli -d DBT3 -u dbm,dbm -uSQL $DBUSER,$DBUSER "sql_execute select task_name, s_time, e_time, timediff(e_time,s_time) from time_statistics"
fi

