#!/bin/sh

echo "define backup medium"
_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
medium_put data $DBT3_BACKUP/datasave FILE DATA 0 8 YES
medium_put incr $DBT3_BACKUP/incremental FILE PAGES 0 8 YES
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "define backup medium failed: $_o"
        exit 1
fi
