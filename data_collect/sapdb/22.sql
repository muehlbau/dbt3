sql_execute explain select cntrycode, count(*) as numcust, sum(c_acctbal) as totacctbal from ( select substr(c_phone, 1, 2) as cntrycode, c_acctbal from customer where substr(c_phone, 1, 2) in ('33', '19', '25', '14', '29', '10', '21') and c_acctbal > ( select avg(c_acctbal) from customer where c_acctbal > 0.00 and substr(c_phone, 1, 2) in ('33', '19', '25', '14', '29', '10', '21') ) and  c_custkey not in (select o_custkey from orders) ) group by cntrycode order by cntrycode

sql_execute select * from show
