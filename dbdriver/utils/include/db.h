#ifndef _DB_H
#define _DB_H

#ifdef EXPLAIN
#ifdef sapdb
#define SQL_EXEC "sql_execute explain"
#endif
#ifdef pgsql
#define SQL_EXEC "explain"
#endif
#else
#ifdef sapdb
#define SQL_EXEC "sql_execute"
#endif
#ifdef pgsql
#define SQL_EXEC ""
#endif
#endif

#ifdef sapdb
#define SQL_TIME_P_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.POWER.Q%d', timestamp)\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=timestamp where task_name='PERF%d.POWER.Q%d'\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', timestamp)\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=timestamp where task_name='PERF%d.THRUPUT.QS%d.Q%d'\n"
#define SQL_ISOLATION "sql_execute set isolation level 2"
#define SQL_COMMIT "commit"
#endif
#ifdef pgsql
#define SQL_TIME_P_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.POWER.Q%d', current_timestamp);\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=current_timestamp where task_name='PERF%d.POWER.Q%d';\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', current_timestamp);\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=current_timestamp where task_name='PERF%d.THRUPUT.QS%d.Q%d';\n"
#define SQL_ISOLATION "set default_transaction_isolation='read committed';"
#define SQL_COMMIT ""
#endif

#endif
