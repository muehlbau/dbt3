truncate region;
\set AUTOCOMMIT off
COPY region FROM '/tmp/region.tbl' USING DELIMITERS '|';
commit;
