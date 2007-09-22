CREATE TABLE orders (
	o_orderkey INTEGER comment "<nitro>KEYSPN=256,NODES=8192,BATCH='Y',VLDBIndex='1,orders1_?.index,1,9999,2000000000,1'</nitro>",
	o_custkey INTEGER comment "<nitro>KEYSPN=256,NODES=8192,BATCH='Y',VLDBIndex='2,orders2_?.index,1,9999,2000000000,2'</nitro>",
	o_orderstatus CHAR(1),
	o_totalprice DECIMAL(10,2),
	o_orderDATE DATE comment "<nitro>KEYSPN=256,NODES=8192,BATCH='Y',VLDBIndex='3,orders3_?.index,1,9999,2000000000,2'</nitro>",
	o_orderpriority CHAR(15),
	o_clerk CHAR(15),
	o_shippriority INTEGER,
	o_comment VARCHAR(79),
	PRIMARY KEY (o_orderkey) , 
	index i_o_orderdate (o_orderdate), 
	index i_o_custkey (o_custkey)
) comment "<nitro>VLDB='Y',VLDBDataCacheSize=1000000,VLDBData='1,orders?.data,1,9999,2000000000',DefaultBatchSize=150000,DefaultBatchTime=5</nitro>";
