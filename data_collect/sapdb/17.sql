sql_execute explain select sum(l_extendedprice) / 7.0 as avg_yearly from lineitem, part where p_partkey = l_partkey and p_brand = 'Brand#22' and p_container = 'WRAP CAN' and l_quantity < ( select 0.2 * avg(l_quantity) from lineitem where l_partkey = p_partkey )
sql_execute select * from show
