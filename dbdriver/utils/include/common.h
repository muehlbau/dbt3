#ifndef _COMMON_H
#define _COMMON_H

#define TRUE 1
#define FALSE 0
#define OK 0
#define ERROR -1
#define BEGIN_OF_BLOCK 8
#define END_OF_BLOCK 2
#define END_OF_STMT 3
#define END_OF_FILE 4
#define POWER 5
#define THROUGHPUT 6
#define SINGLE 7

struct sql_statement_t
{
	int rowcount;
	char statement[1024];
	char comment[256];
	int query_id;
};

int get_statement(FILE *query_input);
void ltrim(char *str);

#endif
