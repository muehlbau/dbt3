sql_execute explain select sum(l_extendedprice * l_discount) as revenue from lineitem where l_shipdate >= '1997-01-01' and l_shipdate < adddate('1997-01-01', 365) and l_discount between 0.04 - 0.01 and 0.04 + 0.01 and l_quantity < 24
sql_execute select * from show
