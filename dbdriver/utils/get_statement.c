#include <stdio.h>
#include <stdlib.h>

#include "common.h"
#include "get_statement.h"

int get_statement(FILE *query_input)
{
	char line[128];
	char *pos, *str;
	int comment_index, statement_index;

	sql_statement.statement[0]='\0';
	sql_statement.comment[0]='\0';
	comment_index=0;
	statement_index=0;

	while (fgets(line, 127, query_input) != NULL)
	{
		/* skip the blank lines */
		if (line[0] == '\n')
			continue;

		/* remove the leading spaces */
		ltrim(line);

		/* if this is a comment line, store it to statement.comment */
		if (line[0]=='-' && line[1]=='-') 
		{
			comment_index += sprintf(sql_statement.comment+comment_index, "%s", line);
		}
		/* if this is a 'set row' line, store the row count */
		else if (strncmp(line, "set rowcount", 12) == 0)
		{
			pos=line+13;
			sql_statement.rowcount=atoi(pos);
		}
		/* if it is "go", then this is the end of this block */
		else if (strcmp(line,"go\n") == 0)
			return TRUE;
		/* otherwise, it is sql statement */
		else
		{
			/* get rid of ';' at the end */
			if ( (pos=strchr(line, ';')) != NULL)
				*pos='\0';
			statement_index += sprintf(sql_statement.statement+statement_index, "%s", line);
		}
	}
	return FALSE;
}

void ltrim(char *str)
{
	char *start_pos;

	start_pos=str;
	while (*start_pos == ' ') start_pos++;
	strcpy(str, start_pos);
}
