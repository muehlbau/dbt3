create index i_l_shipdate on lineitem (l_shipdate);

create index i_l_suppkey_partkey on lineitem (l_partkey, l_suppkey);

create index i_l_partkey on lineitem (l_partkey);

create index i_l_suppkey on lineitem (l_suppkey);

create index i_l_receiptdate on lineitem (l_receiptdate);

create index i_l_orderkey on lineitem (l_orderkey);

create index i_l_orderkey_quantity on lineitem (l_orderkey, l_quantity);

create index i_c_nationkey on customer (c_nationkey);

create index i_o_orderdate on orders (o_orderdate);

create index i_o_custkey on orders (o_custkey);

create index i_s_nationkey on supplier (s_nationkey);

create index i_ps_partkey on partsupp (ps_partkey);

create index i_ps_suppkey on partsupp (ps_suppkey);

create index i_n_regionkey on nation (n_regionkey);
