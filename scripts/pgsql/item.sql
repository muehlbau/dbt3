truncate item;
\set AUTOCOMMIT off
COPY item FROM '/tmp/item.data' USING DELIMITERS '\\';
commit ;
