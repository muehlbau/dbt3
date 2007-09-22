CREATE TABLE supplier (
	s_suppkey  INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	s_name CHAR(25),
	s_address VARCHAR(40),
	s_nationkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	s_phone CHAR(15),
	s_acctbal DECIMAL (10,2),
	s_comment VARCHAR(101),
	PRIMARY KEY (s_suppkey) ,
	index i_s_nationkey (s_nationkey)
);
