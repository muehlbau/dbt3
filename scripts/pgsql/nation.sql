truncate nation;
\set AUTOCOMMIT off
COPY nation FROM '/tmp/nation.tbl' USING DELIMITERS '|';
commit;
