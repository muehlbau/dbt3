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
	cd $DBT3_INSTALL_PATH/datagen/dbgen
	date
	$DBT3_INSTALL_PATH/datagen/dbgen/dbgen -s $SF
	echo "data files are generated"
	date
	cd $DBT3_INSTALL_PATH/scripts/sapdb
else
	echo "build the database without generating the data files"
fi
	echo "drop db"
	$DBT3_INSTALL_PATH/scripts/sapdb/drop_db.sh
	echo
	
	echo "create db"
	$DBT3_INSTALL_PATH/scripts/sapdb/create_db.sh
	echo
	
	echo "create tables"
	$DBT3_INSTALL_PATH/scripts/sapdb/create_tables.sh
	echo
	
	date
	echo "start loading db"
	$DBT3_INSTALL_PATH/scripts/sapdb/load_db.sh
	date
	echo "loading db done"
	
	echo "starting to create indexes"
	date
	
	date
	echo "start creating indexes"
	$DBT3_INSTALL_PATH/scripts/sapdb/create_indexes.sh
	date
	echo "creating indexes done"
	
	
	date
	echo "start updating optimizer statistics"
	$DBT3_INSTALL_PATH/scripts/sapdb/update_statistics.sh
	date
	echo "updating optimizer statistics done"
	
	date
	echo "start backup database"
	$DBT3_INSTALL_PATH/scripts/sapdb/backup_db.sh
	date
	echo "backup done"
	
	date
