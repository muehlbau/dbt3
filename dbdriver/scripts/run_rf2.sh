#!/bin/sh

GTIME="$DBT3_INSTALL_PATH/dbdriver/utils/gtime"
curr_set_file_rf1="$DBT3_INSTALL_PATH/run/curr_set_num_rf1"
curr_set_file_rf2="$DBT3_INSTALL_PATH/run/curr_set_num_rf2"
lock_file_rf1="$DBT3_INSTALL_PATH/run/rf1.lock"
lock_file_rf2="$DBT3_INSTALL_PATH/run/rf2.lock"

#if set_num_file_rf1 does not exist, exit since rf1 has to run before rf2
lockfile -s 0 $lock_file_rf1
if [ ! -f $curr_set_file_rf1 ];
then
        echo "please run run_rf1.sh first"
	exit
fi
set_num_rf1=`cat $curr_set_file_rf1`
rm -f $lock_file_rf1

lockfile -s 0 $lock_file_rf2
if [ ! -f $curr_set_file_rf2 ];
then
	echo 0 > $curr_set_file_rf2
fi

set_num=`cat $curr_set_file_rf2`

let "set_num=$set_num+1"
if [ $set_num -gt $set_num_rf1 ]
then
	echo "rf2 set number is greater than rf1 set number"
	echo "please run run_rf1.sh first"
	exit
fi

echo $set_num>$curr_set_file_rf2
rm -f $lock_file_rf2

echo "=======rf2 set: $set_num========"

echo "`date`: start rf2 "
s_time=`$GTIME`

#generate load .sql
echo "fastload table tmp_orderkey$set_num" > tmp_orderkey$set_num.sql
echo "orderkey 1" >> tmp_orderkey$set_num.sql
echo "infile '/tmp/delete.$set_num'" >> tmp_orderkey$set_num.sql

echo "sql_execute drop table tmp_orderkey$set_num"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute drop table tmp_orderkey$set_num"

echo "sql_execute create table tmp_orderkey$set_num (orderkey fixed(10))"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute create table tmp_orderkey$set_num (orderkey fixed(10))"

echo "load tmp_orderkey$set_num"
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d $SID -b tmp_orderkey$set_num.sql

echo "sql_execute delete from lineitem where l_orderkey in (select * from tmp_orderkey$set_num)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute delete from lineitem where l_orderkey in (select * from tmp_orderkey$set_num)"

echo "sql_execute delete from orders where o_orderkey in (select * from tmp_orderkey$set_num)"
dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute delete from orders where o_orderkey in (select * from tmp_orderkey$set_num)"

#clean up
echo "sql_execute drop table tmp_orderkey$set_num"
rm -f tmp_orderkey$set_num.sql

dbmcli -d $SID -u dbm,dbm -uSQL dbt,dbt "sql_execute drop table tmp_orderkey$set_num"
rm tmp_orderkey$set_num.sql
e_time=`$GTIME`
echo "`date`: end rf2 "
let "diff_time=$e_time-$s_time"
echo "elapsed time for rf2 $diff_time"
