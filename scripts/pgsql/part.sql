truncate part;
SET autocommit = false;
COPY part FROM '/tmp/part.tbl' USING DELIMITERS '|';
commit;
