echo "recover db"
pg_restore -v Fc -a -d $SID $DBT3_BACKUP
echo

