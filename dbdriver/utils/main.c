#include <stdio.h>

#include "common.h"
#include "get_statement.h"
#include "sql_exec.h"

struct sql_statement_t sql_statement;
int main(int argc, char *argv[])
{
	FILE *query_input;
	char query_file_name[60];
	int rc;
	char dbname[40];
	char hostname[40];
	
	if (argc != 4)
	{
		printf("usage ./argv[0] query_file, hostname, dbname\n");
		exit(1);
	}
	
	init_common();

	strcpy(query_file_name, argv[1]);
	strcpy(hostname, argv[2]);
	strcpy(dbname, argv[3]);

	rc=db_connect(dbname,hostname);
	if (rc!=0) 
	{
		LOG_ERROR_MESSAGE("db_connect failed: %d\n", rc);
		printf("db_connect error\n");
		exit(-1);
	}
	else printf("db_connect passed\n");

	if ( (query_input=fopen(query_file_name, "r")) == NULL)
	{
		LOG_ERROR_MESSAGE("can not open file %s\n", query_file_name);
		printf("can not open file %s\n", query_file_name);
		exit(-1);
	}

	while ( (rc=get_statement(query_input)) == TRUE)
	{
#ifdef DEBUG
		LOG_DEBUG_MESSAGE("comment: %s\n", sql_statement.comment);
		LOG_DEBUG_MESSAGE("statement: %s\n", sql_statement.statement);
		LOG_DEBUG_MESSAGE("fetch row: %d\n", sql_statement.rowcount);
#endif
	}

	printf("end of file\n");
}
