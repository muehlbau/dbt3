#!/bin/sh
date
repmcli -u dbt,dbt -d $SID -b supplier.sql
date
repmcli -u dbt,dbt -d $SID -b part.sql
date
repmcli -u dbt,dbt -d $SID -b partsupp.sql
date
repmcli -u dbt,dbt -d $SID -b customer.sql
date
repmcli -u dbt,dbt -d $SID -b orders.sql
date
repmcli -u dbt,dbt -d $SID -b lineitem.sql
date
repmcli -u dbt,dbt -d $SID -b nation.sql
date
repmcli -u dbt,dbt -d $SID -b region.sql
date
