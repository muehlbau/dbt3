CREATE TABLE orders (
	o_orderkey INTEGER,
	o_custkey INTEGER,
	o_orderstatus CHAR(1),
	o_totalprice DECIMAL(10,2),
	o_orderDATE DATE,
	o_orderpriority CHAR(15),
	o_clerk CHAR(15),
	o_shippriority INTEGER,
	o_comment VARCHAR(79),
	PRIMARY KEY (o_orderkey) , 
	index i_o_orderdate (o_orderdate), 
	index i_o_custkey (o_custkey)
);
