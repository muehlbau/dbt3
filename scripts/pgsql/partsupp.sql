truncate partsupp;
SET autocommit = false;
COPY partsupp FROM '/tmp/partsupp.tbl' USING DELIMITERS '|';
commit;
