#!/bin/sh
set -x

# assumes the user created database files is the last one
# will not work if there are more than 1 user created database
for i in $PGDATA/base/*
do
#	if [$i > 17000]; then
	dbdir=$i
done

rm -rf $dbdir/pgsql_tmp
ln -s /db_tmp $dbdir/pgsql_tmp
