#!/bin/sh

psql $SID -U $USER -f $DBT3_INSTALL_PATH/scripts/pgsql/drop_tables.sql
