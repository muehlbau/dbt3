SET autocommit = false ;
COPY item FROM '/tmp/item.data' USING DELIMITERS '\\';
commit ;
