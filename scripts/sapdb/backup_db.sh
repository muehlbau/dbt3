#!/bin/sh

_o=`cat <<EOF | /opt/sapdb/depend/bin/dbmcli -d DBT3 -u dbm,dbm 2>&1
util_connect dbm,dbm
backup_start data
autolog_on
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "backup failed: $_o"
        exit 1
fi
