vacuumdb -z $SID
psql $SID -c "analyze supplier"
psql $SID -c "analyze part"
psql $SID -c "analyze partsupp"
psql $SID -c "analyze customer"
psql $SID -c "analyze orders"
psql $SID -c "analyze lineitem"
psql $SID -c "analyze nation"
psql $SID -c "analyze region"
