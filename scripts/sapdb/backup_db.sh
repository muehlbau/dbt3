#!/bin/sh

echo "set backup parameters..."
_o=`cat <<EOF | /opt/sapdb/depend/bin/dbmcli -d $SID -u dbm,dbm 2>&1
medium_put data /dbt3/datasave FILE DATA 0 8 YES
medium_put incr /dbt3/incremental FILE PAGES 0 8 YES
medium_put auto /dbt3/autosave FILE AUTO
util_connect dbm,dbm
backup_start data migration
backup_start incr migration
autolog_on
util_release
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "backup failed: $_o"
        exit 1
fi
