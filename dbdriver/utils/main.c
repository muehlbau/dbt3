#include <stdio.h>
#include <stdlib.h>
#include <common.h>

#include "get_statement.h"

struct sql_statement_t sql_statement;

main(int argc, char *argv[])
{
	FILE *query_input;
	FILE *query_output;
	char query_input_file_name[60];
	char query_output_file_name[60];
	int rc;
	int perf_run_number;
	int stream_number;
	int run_type;

	/* flag indicating if the current is the first statement in this block*/
	int first_stmt;
	
	first_stmt=TRUE;
	if (argc < 4)
	{
		printf("usage: \n%s <query_input_file> <query_output_file> <S>\n", argv[0]);
		printf("%s <query_input_file> <query_output_file> <P> <perf_run_number> \n", argv[0]);
		printf("%s <query_input_file> <query_output_file> <T> <perf_run_number> <throughput_query_stream_number>\n", argv[0]);
		exit(1);
	}
	
	strcpy(query_input_file_name, argv[1]);
	strcpy(query_output_file_name, argv[2]);
	if (strcmp(argv[3], "P")==0 || strcmp(argv[3],"p")==0)
	{
		run_type = POWER;
		perf_run_number = atoi(argv[4]);
	}
	else if (strcmp(argv[3], "S")==0 || strcmp(argv[3], "s") == 0)
		run_type = SINGLE;
	else if (strcmp(argv[3], "T")==0 || strcmp(argv[3], "t") == 0)
	{
		run_type = THROUGHPUT;
		perf_run_number = atoi(argv[4]);
		stream_number = atoi(argv[5]);
	}
	else
	{
		printf("run type: P -- power test  T -- throughput test  S -- single query\n");
		exit(1);
	}
	

	if ( (query_input=fopen(query_input_file_name, "r")) == NULL)
	{
		printf("can not open file %s\n", query_input_file_name);
		exit(-1);
	}

	if ( (query_output=fopen(query_output_file_name, "w")) == NULL)
	{
		printf("can not open file %s\n", query_output_file_name);
		exit(-1);
	}

	fprintf(query_output, "sql_execute set format ISO\n\n");
	//fprintf(query_output, "sql_execute delete * from time_statistic\n\n");

	while ( (rc=get_statement(query_input)) != END_OF_FILE)
	{
		/* if this is the first statement in this block */
		if (rc == END_OF_STMT && first_stmt == TRUE)
		{
			if (run_type == POWER)
				fprintf(query_output, "%s insert into time_statistic (task_name, s_time) values ('PERF%d.POWER.Q%d', timestamp)\n", SQL_EXEC, perf_run_number, sql_statement.query_id);
			else if (run_type == THROUGHPUT)
				fprintf(query_output, "%s insert into time_statistic (task_name, s_time) values ('PERF%d.THUPUT.QS%d.Q%d', timestamp)\n", SQL_EXEC, perf_run_number, stream_number, sql_statement.query_id);
			first_stmt = FALSE;
		}
		if (rc == END_OF_STMT)
			fprintf(query_output, "%s %s", SQL_EXEC, sql_statement.statement);
		if (rc == END_OF_BLOCK)
		{
			first_stmt = TRUE;
			if (run_type == POWER)
				fprintf(query_output, "%s update time_statistic set e_time=timestamp where task_name='PERF%d.POWER.Q%d'\n\n", SQL_EXEC, perf_run_number, sql_statement.query_id);
			else if (run_type == THROUGHPUT)
				fprintf(query_output, "%s update time_statistic set e_time=timestamp where task_name='PERF%d.THUPUT.QS%d.Q%d'\n\n", SQL_EXEC, perf_run_number, stream_number, sql_statement.query_id);
		}
	}
	

	fclose(query_input);
	fclose(query_output);
}
