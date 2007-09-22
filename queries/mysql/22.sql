-- @(#)22.sql	2.1.8.1
-- TPC-H/TPC-R Global Sales Opportunity Query (Q22)
-- Functional Query Definition
-- Approved February 1998
:b
:o
:x
select 
  avg(c_acctbal) 
from 
  customer 
where c_acctbal > 0.00
      and substr(c_phone,1,2) in 
      (':1', ':2', ':3', ':4', ':5', ':6', ':7')
into @avgacctbal; 
:x
select
	substr(c_phone, 1, 2) as cntrycode,
	count(*) as numcust,
	sum(c_acctbal) as totacctbal
from
	customer
left join orders on o_custkey = c_custkey 
where
	substr(c_phone, 1, 2) in
	(':1', ':2', ':3', ':4', ':5', ':6', ':7')
	and c_acctbal > @avgacctbal 
	and o_custkey is null 
group by
	cntrycode
order by
	cntrycode;
:e
