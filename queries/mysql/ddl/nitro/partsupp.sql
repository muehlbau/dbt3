CREATE TABLE partsupp (
	ps_partkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	ps_suppkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	ps_availqty INTEGER,
	ps_supplycost DECIMAL(10,2),
	ps_comment VARCHAR(199),
	PRIMARY KEY (ps_partkey, ps_suppkey) comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	index i_ps_partkey (ps_partkey),
	index i_ps_suppkey (ps_suppkey)
);
