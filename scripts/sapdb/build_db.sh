#!/bin/sh
#this script is used to build the database
# ./build_db.sh -g <items> <eus> will generate data and build the database
# ./build_db.sh will load the database from previously generated data files

if [ $# -ne 0 ] # Script invoked with command-line args
then
	getopts "g" Option
	if [ $Option != "g" ]
		then echo "usage: $0 -g <scale_factor>" 
		exit 1
	else
		if [ $# -ne 2 ]
			then echo "usage: $0 -g <scale_factor>" 
			exit 1
		else
			SF=$2
		fi
	fi

	echo "Generating data... scale factor $SF"
	cd ../../datagen/dbgen
	date
	./dbgen -s $SF
	echo "data files are generated"
	date
	cd ../../scripts/sapdb
else
	echo "build the database without generating the data files"
fi
	echo "drop db"
	./drop_db.sh
	echo
	
	echo "create db"
	./create_db.sh
	echo
	
	echo "create tables"
	./create_tables.sh
	echo
	
	date
	echo "start loading db"
	./load_db.sh
	date
	echo "loading db done"
	
	echo "starting to create indexes"
	date
	
	date
	echo "start creating indexes"
	./create_indexes.sh
	date
	echo "creating indexes done"
	
	
	date
	echo "start updating optimizer statistics"
	./update_statistics.sh
	date
	echo "updating optimizer statistics done"
	
	date
	echo "start backup database"
	./backup_db.sh
	date
	echo "backup done"
	
	date
