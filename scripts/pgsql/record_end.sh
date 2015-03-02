#!/bin/bash

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2004-2006 Mark Wong & Open Source Development Labs, Inc.
#

while getopts "l:n:" opt; do
	case $opt in
	l)
		DBPORT=${OPTARG}
		;;
	n)
		NAME=$OPTARG
		;;
	esac
done

dbt3-pgsql-time-statistics -e -l ${DBPORT} -n ${NAME}
