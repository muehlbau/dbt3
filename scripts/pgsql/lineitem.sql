truncate lineitem;
SET autocommit = false;
COPY lineitem FROM '/tmp/lineitem.tbl' USING DELIMITERS '|';
commit;
