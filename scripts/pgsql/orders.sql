truncate orders;
\set AUTOCOMMIT off
COPY orders FROM '/tmp/orders.tbl' USING DELIMITERS '|';
commit;
