# Makefile
# 20 february 2002

include ../common.mk

INCLUDE_DIR=../include
COMMON_DIR=../common

EXE = parse_query
UTIL_PRGS = main.c get_statement.c
UTIL_OBJS = $(UTIL_PRGS:.c=.so)

OBJS = $(UTIL_OBJS) $(COMMON_OBJS)
PRGS = $(UTIL_PRGS) $(COMMON_PRGS)

all: $(EXE) gtime

$(EXE): $(OBJS)
	$(CC) -o $@ $(OBJS)

gtime:	get_time.c
	$(CC) -o gtime get_time.c

%.so:%.c
	$(CC) -c -shared -fpic $(CFLAGS) -o $@ $<

clean:
	rm -f $(EXE) *.so *.o
	
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

