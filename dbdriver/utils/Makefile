# Makefile
# 20 february 2002

CC = gcc

INCLUDE_DIR=../include
CFLAGS = -g -I$(INCLUDE_DIR) -DDEBUG

EXE = parse_query
UTIL_PRGS = main.c get_statement.c
UTIL_OBJS = $(UTIL_PRGS:.c=.so)

OBJS = $(UTIL_OBJS)
PRGS = $(UTIL_PRGS)

all: parse_query gtime

parse_query: $(OBJS)
	$(CC) -o $@ $(OBJS)

gtime:	get_time.c
	$(CC) -o gtime get_time.c

%.so:%.c
	$(CC) -c -shared -fpic $(CFLAGS) -o $@ $<

clean:
	rm -f parse_query gtime *.so *.o
	
explain:
	@echo "$(OBJS)"

$(EXE): \
	../common.mk \
	Makefile \
	$(OBJS) \
	$(INCLUDE_DIR)/get_statement.h 

$(OBJS): \
	../common.mk \
	Makefile \
	$(INCLUDE_DIR)/get_statement.h \
	$(PRGS)

