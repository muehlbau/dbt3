truncate supplier;
\set AUTOCOMMIT off
COPY supplier FROM '/tmp/supplier.tbl' USING DELIMITERS '|';
commit;
