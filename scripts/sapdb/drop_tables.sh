#!/bin/sh

/opt/sapdb/depend/bin/dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt -i drop_tables.sql
