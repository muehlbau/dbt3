sql_execute explain select l_shipmode, sum(decode(o_orderpriority, '1-URGENT', 1, '2-HIGH',1, 0)) as high_line_count, sum(decode(o_orderpriority, '1-URGENT', 0, '2-HIGH',0, 1)) as low_line_count from orders, lineitem where o_orderkey = l_orderkey and l_shipmode in ('FOB', 'REG AIR') and l_commitdate < l_receiptdate and l_shipdate < l_commitdate and l_receiptdate >= '1997-01-01' and l_receiptdate < adddate('1997-01-01', 365) group by l_shipmode order by l_shipmode

sql_execute select * from show
