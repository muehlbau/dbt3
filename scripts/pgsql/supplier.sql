truncate supplier;
SET autocommit = false;
COPY supplier FROM '/tmp/supplier.tbl' USING DELIMITERS '|';
commit;
