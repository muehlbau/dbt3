#!/bin/sh
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/supplier.sql
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/part.sql
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/partsupp.sql
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/customer.sql
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/orders.sql
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/lineitem.sql
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/nation.sql
date
repmcli -u dbt,dbt -d $SID -b $DBT3_INSTALL_PATH/scripts/sapdb/region.sql
date
