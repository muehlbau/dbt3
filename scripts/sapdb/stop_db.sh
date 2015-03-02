#!/bin/bash
dbmcli -d $SID -u dbm,dbm db_cold
dbmcli -d $SID -u dbm,dbm db_offline
