truncate lineitem;
\set AUTOCOMMIT off
COPY lineitem FROM '/tmp/lineitem.tbl' USING DELIMITERS '|';
commit;
