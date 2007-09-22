-- @(#)21.sql	2.1.8.1
-- TPC-H/TPC-R Suppliers Who Kept Orders Waiting Query (Q21)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
select
	s_name,
	count(*) as numwait
from
	lineitem l1
join supplier
	on s_suppkey = l1.l_suppkey 
join nation
	on s_nationkey = n_nationkey
join orders 
        on o_orderkey = l1.l_orderkey
join lineitem l2
	on l2.l_orderkey = l1.l_orderkey
	and l2.l_suppkey <> l1.l_suppkey
left join 
        lineitem l3 
        on l3.l_orderkey = l1.l_orderkey 
	and l3.l_suppkey <> l1.l_suppkey
	and l3.l_receiptdate > l3.l_commitdate
where
	l1.l_receiptdate > l1.l_commitdate
	and o_orderstatus = 'F'
        and l3.l_orderkey is null
	and n_name = 'CANADA'
group by
	s_name
order by
	numwait desc,
	s_name
:n 100
:e
