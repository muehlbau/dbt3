truncate orders;
SET autocommit = false;
COPY orders FROM '/tmp/orders.tbl' USING DELIMITERS '|';
commit;
