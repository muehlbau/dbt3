CREATE TABLE customer (
	c_custkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	c_name VARCHAR(25),
	c_address VARCHAR(40),
	c_nationkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	c_phone CHAR(15),
	c_acctbal DECIMAL(10,2),
	c_mktsegment CHAR(10),
	c_comment VARCHAR(117),
	PRIMARY KEY (c_custkey) ,
	index i_c_nationkey (c_nationkey)
);
