#!/bin/sh

/opt/sapdb/depend/bin/dbmcli -s -d DBT3 -u dbm,dbm db_stop
/opt/sapdb/depend/bin/dbmcli -s -d DBT3 -u dbm,dbm db_offline
/opt/sapdb/depend/bin/dbmcli -s -d DBT3 -u dbm,dbm db_drop
