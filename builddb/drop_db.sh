#!/bin/sh

dbmcli -s -d $SID -u dbm,dbm db_stop
dbmcli -s -d $SID -u dbm,dbm db_offline
dbmcli -s -d $SID -u dbm,dbm db_drop
