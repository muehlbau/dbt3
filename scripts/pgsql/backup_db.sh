#!/bin/sh

echo "start backup"
./define_medium.sh

_test=`pg_dump $SID --file=$DBT3_BACKUP | grep OK`
if [ "$_test" != "" ]; then
        echo "backup failed: $_o"
        exit 1
fi
