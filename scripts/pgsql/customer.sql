truncate customer;
\set AUTOCOMMIT off
COPY customer FROM '/tmp/customer.tbl' USING DELIMITERS '|';
commit;
