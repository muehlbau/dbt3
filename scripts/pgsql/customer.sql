truncate customer;
SET autocommit = false;
COPY customer FROM '/tmp/customer.tbl' USING DELIMITERS '|';
commit;
