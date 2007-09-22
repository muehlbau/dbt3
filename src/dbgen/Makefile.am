
# Current values for DATABASE are: INFORMIX, DB2, TDAT (Teradata)
#                                  SQLSERVER, SYBASE, PGSQL (PostgreSQL)
# Current values for WORKLOAD are:  TPCH, TPCR
WORKLOAD=TPCH
#
# add -EDTERABYTE if orderkey will execeed 32 bits (SF >= 300)
# and make the appropriate change in gen_schema() of runit.sh
AM_CFLAGS = -DDBNAME=\"dss\" -DSTDLIB_HAS_GETOPT -DEOL_HANDLING -D_FILE_OFFSET_BITS=64 
AM_LDFLAGS = -O

bin_PROGRAMS = dbgen qgen
dbgen_SOURCES = build.c driver.c bm_utils.c rnd.c print.c load_stub.c bcd2.c \
	speed_seed.c text.c permute.c
qgen_SOURCES = qgen.c varsub.c build.c bm_utils.c rnd.c text.c bcd2.c permute.c speed_seed.c  
EXTRA_DIST = README HISTORY PORTING.NOTES BUGS dss.ddl dss.ri dists.dss makefile.suite 
