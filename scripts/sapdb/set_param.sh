#!/bin/sh

# setup database parameters
echo "set parameters for $SID..."
_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
param_rmfile
param_startsession
param_init
param_put LOG_MODE DEMO
param_put DATA_CACHE 5000
param_put MAXUSERTASKS 10
param_put MAXCPU 2
param_put _IDXFILE_LIST_SIZE 8192
param_put _PACKET_SIZE 131072
param_put DATE_TIME_FORMAT ISO
param_checkall
param_commitsession
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "set parameters failed: $_o"
        exit 1
fi
