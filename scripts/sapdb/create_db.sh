#!/bin/sh
###
# 		dont start script as root!
#		--------------------------
#
# create example database TST with (only for seperated packages - sapdb-ind, sapdb-srv, sapdb-testdb):
#   - 20 MB data devspace and 8 MB log devspace
#   - demo database user test (with password test)
###


id=`id | sed s/\(.*// | sed s/uid=//`

if [ "$id" = "0" ]; then
	echo "dont start script as root"
	exit 1
fi 

# dir where the database system files are
SYS_DIR="/home/sapdb"

# stop and drop probably existing demo database
echo "stop and drop existing $SID..."
dbmcli -d $SID -u dbm,dbm db_offline >/dev/null 2>&1
dbmcli -d $SID -u dbm,dbm db_drop >/dev/null 2>&1

# create new demo database
echo "create database $SID..."
_o=`/opt/sapdb/depend/bin/dbmcli -s -R /opt/sapdb/depend db_create $SID dbm,dbm 2>&1`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
	echo "create $SID failed: $_o"
	exit 1
fi

# create directory where to put the system files
mkdir -p $SYS_DIR/$SID

# setup database parameters
echo "set parameters for $SID..."
$DBT3_INSTALL_PATH/scripts/sapdb/set_param.sh 0
# devsapce definition
_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
param_adddevspace 1 SYS  $SYS_DIR/$SID/DBT3_SYS_001   F
param_adddevspace 1 DATA /dev/raw/raw11  R 150000
param_adddevspace 2 DATA /dev/raw/raw12  R 150000
param_adddevspace 3 DATA /dev/raw/raw13  R 150000
param_adddevspace 4 DATA /dev/raw/raw14  R 150000
param_adddevspace 5 DATA /dev/raw/raw15  R 150000
param_adddevspace 6 DATA /dev/raw/raw16  R 150000
param_adddevspace 7 DATA /dev/raw/raw17  R 150000
param_adddevspace 1 LOG /dev/raw/raw18  R 150000
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "set parameters failed: $_o"
        exit 1
fi

# startup database
echo "start $SID..."
_o=`dbmcli -d $SID -u dbm,dbm db_start 2>&1`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "start $SID failed: $_o"
        exit 1
fi


# initialize database files
echo "initializing $SID..."
_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
util_connect dbm,dbm
util_execute init config
util_activate dba,dba
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "initialize $SID failed: $_o"
        exit 1
fi

# load database system tables
echo "load system tables..."
_o=`dbmcli -d $SID -u dbm,dbm load_systab -u dba,dba -ud domain 2>&1`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "load system tables failed: $_o"
        exit 1
fi

# create database demo user
echo "create database demo user..."
_o=`cat <<EOF | dbmcli -d $SID -u dba,dba 2>&1
sql_connect dba,dba
sql_execute CREATE USER dbt PASSWORD dbt DBA NOT EXCLUSIVE
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "create db user failed: $_o"
        exit 1
fi

exit 0
