#!/bin/sh

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2004-2006 Mark Wong & Open Source Development Labs, Inc.
#

while getopts "l:n:" opt; do
	case $opt in
	n)
		NAME=$OPTARG
		;;
	esac
done

dbt3-mysql-time-statistics -e -n ${NAME}
