# Makefile
# 20 february 2002

include ../common.mk

COMMON_DIR=../common
INCLUDE_DIR=../include

EXE = execute_query
SQL_PRGS = main.c get_statement.c
SQL_OBJS = $(SQL_PRGS:.c=.so)
PCP_PRGS = db_connect.cpc sql_exec.cpc
PCP_OBJS = $(PCP_PRGS:.cpc=.o)
PCP_MIDDLE = $(PCP_PRGS:.cpc=.c)

OBJS = $(COMMON_OBJS) $(SQL_OBJS) $(PCP_OBJS)
PRGS = $(COMMON_PRGS) $(SQL_PRGS)

all: $(EXE)

$(EXE): $(OBJS)
	$(CC) -o $@ $(OBJS) -L/opt/sapdb/interfaces/precompiler/lib -lpcrl -lsqlca -ldl

%.o:%.cpc
	cpc -d DBT3 -u dbt,dbt db_connect
	cpc -d DBT3 -u dbt,dbt sql_exec

%.so:%.c
	$(CC) -c -shared -fpic $(CFLAGS) -DDEBUG -o $@ $<


clean:
	rm -f $(EXE) *.so *.o
	rm -f $(PCP_MIDDLE)
	
explain:
	@echo "$(OBJS)"

$(EXE): \
	../common.mk \
	Makefile \
	$(OBJS) \
	$(INCLUDE_DIR)/common.h \
	$(INCLUDE_DIR)/get_statement.h 

$(OBJS): \
	../common.mk \
	Makefile \
	$(INCLUDE_DIR)/common.h \
	$(INCLUDE_DIR)/get_statement.h \
	$(PRGS)

