#!/bin/sh
dbmcli -d $SID -u dbm,dbm db_start
dbmcli -d $SID -u dbm,dbm db_warm
