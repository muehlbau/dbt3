truncate part;
\set AUTOCOMMIT off
COPY part FROM '/tmp/part.tbl' USING DELIMITERS '|';
commit;
