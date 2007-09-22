CREATE TABLE `part` (
	p_partkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	p_name VARCHAR(55),
	p_mfgr CHAR(25),
	p_brand CHAR(10),
	p_type VARCHAR(25),
	p_size INTEGER,
	p_container CHAR(10),
	p_retailprice DECIMAL(10,2),
	p_comment VARCHAR(23),
PRIMARY KEY (p_partkey)
);
