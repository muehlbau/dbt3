sql_execute explain select s_name, s_address from supplier, nation where s_suppkey in ( select distinct (ps_suppkey) from partsupp, part where ps_partkey=p_partkey and p_name like 'blue%' and ps_availqty > ( select 0.5 * sum(l_quantity) from lineitem where l_partkey = ps_partkey and l_suppkey = ps_suppkey and l_shipdate >= '1995-01-01' and l_shipdate < adddate('1995-01-01', 365) ) ) and s_nationkey = n_nationkey and n_name = 'INDIA' order by s_name

sql_execute select * from show
