#!/bin/sh
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b supplier.sql
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b part.sql
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b partsupp.sql
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b customer.sql
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b orders.sql
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b lineitem.sql
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b nation.sql
/opt/sapdb/depend/bin/repmcli -u dbt,dbt -d DBT3 -b region.sql
