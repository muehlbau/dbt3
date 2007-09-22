CREATE TABLE nation (
	n_nationkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	n_name CHAR(25),
	n_regionkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	n_comment VARCHAR(152),
	PRIMARY KEY (n_nationkey), 
	index i_n_regionkey (n_regionkey)
);
