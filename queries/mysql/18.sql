-- @(#)18.sql	2.1.8.1
-- TPC-H/TPC-R Large Volume Customer Query (Q18)
-- Function Query Definition
-- Approved February 1998
:b
:o
drop table if exists temp_lineitems:s; 
create table temp_lineitems:s (
 t_orderkey integer not null, 
 primary key (t_orderkey) 
);
insert into temp_lineitems:s 
  select
    l_orderkey t_orderkey
  from
    lineitem
  group by
    l_orderkey having
  sum(l_quantity) > :1;
:x
select
	c_name,
	c_custkey,
	o_orderkey,
	o_orderdate,
	o_totalprice,
	sum(l_quantity)
from
	customer,
	orders,
	lineitem,
        temp_lineitems:s
where
	o_orderkey = t_orderkey
	and c_custkey = o_custkey
	and o_orderkey = l_orderkey
group by
	c_name,
	c_custkey,
	o_orderkey,
	o_orderdate,
	o_totalprice
order by
	o_totalprice desc,
	o_orderdate
:n 100;

drop table temp_lineitems:s; 

:e
