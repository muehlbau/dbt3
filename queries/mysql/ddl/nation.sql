CREATE TABLE nation (
	n_nationkey INTEGER,
	n_name CHAR(25),
	n_regionkey INTEGER,
	n_comment VARCHAR(152),
	PRIMARY KEY (n_nationkey), 
	index i_n_regionkey (n_regionkey)
);
