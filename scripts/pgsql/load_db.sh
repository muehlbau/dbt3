#!/bin/sh
# load_db.sh
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2002 Open Source Development Lab, Inc.
# History:
# June-4-2003 Create by Jenny Zhang

date
echo -n "loading table supplier..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/supplier.sql
echo "done."

date
echo -n "loading table part..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/part.sql
echo "done."

date
echo -n "loading table partsupp..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/partsupp.sql
echo "done."

date
echo -n "loading table customer..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/customer.sql
echo "done."

date
echo -n "loading table orders..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/orders.sql
echo "done."

date
echo -n "loading table lineitem..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/lineitem.sql
echo "done."

date
echo -n "loading table nation..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/nation.sql
echo "done."

date
echo -n "loading table region..."
psql -U $USER $SID -f $DBT3_INSTALL_PATH/scripts/pgsql/region.sql
echo "done."

