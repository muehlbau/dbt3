#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: ./set_param.sh <0/1>"
	exit
fi

# setup database parameters
echo "set parameters for $SID..."
if [ $1 -eq 0 ]; then
	_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
	param_rmfile
	param_startsession
	param_init
	param_put LOG_MODE DEMO
	param_put DATA_CACHE 262144
	param_put MAXDATADEVSPACES 10
	param_put MAXUSERTASKS 80
	param_put MAXCPU 8
	param_put _IDXFILE_LIST_SIZE 8192
	param_put _PACKET_SIZE 131072
	param_put DATE_TIME_FORMAT ISO
	param_checkall
	param_commitsession
	quit
	EOF`
fi
if [ $1 -eq 1 ]; then
	_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
	db_cold
	param_startsession
	param_put LOG_MODE DEMO
	param_put DATA_CACHE 262144
	param_put MAXDATADEVSPACES 10
	param_put MAXUSERTASKS 80
	param_put MAXCPU 8
	param_put _IDXFILE_LIST_SIZE 8192
	param_put _PACKET_SIZE 131072
	param_put DATE_TIME_FORMAT ISO
	param_checkall
	param_commitsession
	db_stop
	db_start
	db_warm
	quit
	EOF`
fi
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "set parameters failed: $_o"
        exit 1
fi
