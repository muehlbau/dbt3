sql_execute explain select ps_partkey, sum(ps_supplycost * ps_availqty) as value1 from partsupp, supplier, nation where ps_suppkey = s_suppkey and s_nationkey = n_nationkey and n_name = 'ROMANIA' group by ps_partkey having sum(ps_supplycost * ps_availqty) > ( select sum(ps_supplycost * ps_availqty) * 0.0001000000 from partsupp, supplier, nation where ps_suppkey = s_suppkey and s_nationkey = n_nationkey and n_name = 'ROMANIA' ) order by value1 desc

sql_execute select * from show
