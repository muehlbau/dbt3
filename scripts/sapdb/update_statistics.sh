#!/bin/sh

dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt -i $DBT3_INSTALL_PATH/scripts/sapdb/update_statistics.sql
