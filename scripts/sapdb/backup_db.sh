#!/bin/sh

#note: if DATA_CACHE is too big, it should be reduced before backup
#otherwise we get I/O error
echo "changing data_cache to 10000"
_o=`cat <<EOF |  /opt/sapdb/depend/bin/dbmcli -d $SID -u dbm,dbm 2>&1
param_startsession
param_put DATA_CACHE 10000
param_checkall
param_commitsession
quit
EOF`
_test=`echo $_o | grep ERR`
if ! [ "$_test" = "" ]; then
        echo "set parameters failed"
        exit 1
fi

echo "stard backup ..."
_o=`cat <<EOF | /opt/sapdb/depend/bin/dbmcli -d $SID -u dbm,dbm 2>&1
db_stop
db_start
medium_put data /dbt3/datasave FILE DATA 0 8 YES
medium_put incr /dbt3/incremental FILE PAGES 0 8 YES
medium_put auto /dbt3/autosave FILE AUTO
util_connect dbm,dbm
backup_start data migration
backup_start incr migration
util_release
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "backup failed: $_o"
        exit 1
fi
echo "backup done"

echo "set database parameters"
./set_param.sh 1
_o=`cat <<EOF | /opt/sapdb/depend/bin/dbmcli -d $SID -u dbm,dbm 2>&1
db_stop
db_warm
quit
EOF`
