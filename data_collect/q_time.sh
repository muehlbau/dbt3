dbmcli -d DBT3 -u dbm,dbm -uSQL dbt,dbt "sql_execute select task_name, s_time, e_time, timediff(e_time,s_time) from time_statistics"
