#!/bin/sh

psql -f $DBT3_INSTALL_PATH/scripts/pgsql/create_tables.sql $SID
