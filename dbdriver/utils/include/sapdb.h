#ifndef _SAPDB_H
#define _SAPDB_H

#ifdef EXPLAIN
#define SQL_EXEC "sql_execute explain"
#else
#define SQL_EXEC "sql_execute"
#endif

#define SQL_TIME_P_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.POWER.Q%d', timestamp)\n"
#define SQL_TIME_P_UPDATE "%s update time_statistics set e_time=timestamp where task_name='PERF%d.POWER.Q%d'\n\n"
#define SQL_TIME_T_INSERT "%s insert into time_statistics (task_name, s_time) values ('PERF%d.THRUPUT.QS%d.Q%d', timestamp)\n"
#define SQL_TIME_T_UPDATE "%s update time_statistics set e_time=timestamp where task_name='PERF%d.THRUPUT.QS%d.Q%d'\n\n"
#define SQL_COMMIT "sql_execute commit"

#endif
