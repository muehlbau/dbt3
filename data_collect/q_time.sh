dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute select task_name, timediff(e_time,s_time) from time_statistics"
