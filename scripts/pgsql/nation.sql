truncate nation;
SET autocommit = false;
COPY nation FROM '/tmp/nation.tbl' USING DELIMITERS '|';
commit;
