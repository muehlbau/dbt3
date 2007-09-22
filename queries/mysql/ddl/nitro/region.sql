CREATE TABLE region (
	r_regionkey INTEGER comment "<nitro>KEYSPN=256,NODES=4096</nitro>",
	r_name CHAR(25),
	r_comment VARCHAR(152),
	PRIMARY KEY (r_regionkey)
);
