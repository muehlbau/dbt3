truncate partsupp;
\set AUTOCOMMIT off
COPY partsupp FROM '/tmp/partsupp.tbl' USING DELIMITERS '|';
commit;
