sql_execute create index i_l_shipdate on lineitem (l_shipdate asc)
sql_execute commit
sql_execute create index i_l_suppkey_partkey on lineitem (l_partkey asc, l_suppkey asc)
sql_execute commit
sql_execute create index i_l_partkey on lineitem (l_partkey asc)
sql_execute commit
sql_execute create index i_l_suppkey on lineitem (l_suppkey asc)
sql_execute commit
sql_execute create index i_l_receiptdate on lineitem (l_receiptdate asc)
sql_execute commit
sql_execute create index i_l_orderkey on lineitem (l_orderkey asc)
sql_execute commit
sql_execute create index i_l_orderkey_quantity on lineitem (l_orderkey asc, l_quantity asc)
sql_execute commit
sql_execute create index i_c_nationkey on customer (c_nationkey asc)
sql_execute commit
sql_execute create index i_o_orderdate on orders (o_orderdate asc)
sql_execute commit
sql_execute create index i_o_custkey on orders (o_custkey asc)
sql_execute commit
sql_execute create index i_s_nationkey on supplier (s_nationkey asc)
sql_execute commit
sql_execute create index i_ps_partkey on partsupp (ps_partkey asc)
sql_execute commit
sql_execute create index i_ps_suppkey on partsupp (ps_suppkey asc)
sql_execute commit
sql_execute create index i_n_regionkey on nation (n_regionkey asc)
sql_execute commit
