#!/bin/sh

echo "define backup medium"
_o=`cat <<EOF | /opt/sapdb/depend/bin/dbmcli -d $SID -u dbm,dbm 2>&1
medium_put data /dbt3/datasave FILE DATA 0 8 YES
medium_put incr /dbt3/incremental FILE PAGES 0 8 YES
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "define backup medium failed: $_o"
        exit 1
fi
