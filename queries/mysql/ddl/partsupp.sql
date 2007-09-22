CREATE TABLE partsupp (
	ps_partkey INTEGER,
	ps_suppkey INTEGER,
	ps_availqty INTEGER,
	ps_supplycost DECIMAL(10,2),
	ps_comment VARCHAR(199),
	PRIMARY KEY (ps_partkey, ps_suppkey) , 
	index i_ps_partkey (ps_partkey),
	index i_ps_suppkey (ps_suppkey)
);
