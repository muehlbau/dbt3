#ifndef _SAPDB_H
#define _SAPDB_H

#ifdef EXPLAIN
#define SQL_EXEC "sql_execute explain"
#else
#define SQL_EXEC "sql_execute"
#endif

#define SQL_TIME_P_INSERT "insert into time_statistic (task_name, s_time) values (PERF%d.POWER.Q%d, timestamp)"
#define SQL_TIME_P_UPDATE "update time_statistic set e_time=timestamp where task_name=(PERF%d.POWER.Q%d)"
#define SQL_TIME_T_INSERT "insert into time_statistic (task_name, s_time) values (PERF%d.THUPUT.QS%d.Q%d, timestamp)"
#define SQL_TIME_T_UPDATE "update time_statistic set e_time=timestamp where task_name=PERF%d.THUPUT.QS%d.Q%d"

#endif
