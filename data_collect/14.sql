sql_execute explain select 100.00 * sum( decode(substr(p_type, 1, 5), 'PROMO', l_extendedprice*(1-l_discount),0)) / sum(l_extendedprice * (1 - l_discount)) as promo_revenue from lineitem, part where l_partkey = p_partkey and l_shipdate >= '1997-10-01' and l_shipdate < adddate('1997-10-01', 30)
sql_execute select * from show
