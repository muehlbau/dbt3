fastload table supplier s_suppkey 1 s_name 2 s_address 3 s_nationkey 4 s_phone 5 s_acctbal 6 s_comment 7 infile '/tmp/supplier.tbl'
fastload table part p_partkey 1 p_name 2 p_mfgr 3 p_brand 4 p_type 5 p_size 6 p_container 7 p_retailprice 8 p_comment 9 infile '/tmp/part.tbl'
dataload table partsupp ps_partkey 1 ps_suppkey 2 ps_availqty 3 ps_supplycost 4 ps_comment 5 infile '/tmp/partsupp.tbl' COMPRESSED
fastload table customer c_custkey 1 c_name 2 c_address 3 c_nationkey 4 c_phone 5 c_acctbal 6 c_mktsegment 7 c_comment 8 infile '/tmp/customer.tbl'
fastload table orders o_orderkey 1 o_custkey 2 o_orderstatus 3 o_totalprice 4 o_orderdate 5 o_orderpriority 6 o_clerk 7 o_shippriority 8 o_comment 9 infile '/tmp/orders.tbl' date 'yyyy-mm-dd'
fastload table lineitem l_orderkey 1 l_partkey 2 l_suppkey 3 l_linenumber 4 l_quantity 5 l_extendedprice 6 l_discount 7 l_tax 8 l_returnflag 9 l_linestatus 10 l_shipdate 11 l_commitdate 12 l_receiptdate 13 l_shipinstruct 14 l_shipmode 15 l_comment 16 infile '/tmp/lineitem.tbl' date 'yyyy-mm-dd'
fastload table nation n_nationkey 1 n_name 2 n_regionkey 3 n_comment 4 infile '/tmp/nation.tbl'
fastload table region r_regionkey 1 r_name 2 r_comment 3 infile '/tmp/region.tbl'
