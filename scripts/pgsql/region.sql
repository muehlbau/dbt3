truncate region;
SET autocommit = false;
COPY region FROM '/tmp/region.tbl' USING DELIMITERS '|';
commit;
