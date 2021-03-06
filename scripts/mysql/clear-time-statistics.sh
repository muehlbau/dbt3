#!/bin/bash
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2006 Mark Wong & Open Source Development Lab, Inc.
#

DIR=`dirname $0`
. ${DIR}/mysql_profile

mysql --defaults-file=${DEFAULTS_FILE} -D $DBNAME -e "DELETE FROM time_statistics;"
