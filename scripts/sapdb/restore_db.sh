#!/bin/sh

#note: if DATA_CACHE is too big, it should be reduced before restore
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
echo "start restoring db"
_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
db_cold
util_connect dbm,dbm
util_execute INIT CONFIG
recover_start data
recover_start incr
util_release
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "db recover failed: $_o"
        exit 1
fi

echo "set database parameters"
./set_param.sh 1
_o=`cat <<EOF | /opt/sapdb/depend/bin/dbmcli -d $SID -u dbm,dbm 2>&1
db_stop
db_warm
