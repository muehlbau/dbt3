#!/bin/sh

dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt -i update_statistics.sql
