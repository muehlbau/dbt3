echo "restore db"
./define_medium.sh
pg_restore -v Fc -a -d $SID1 $SID1_BACKUP
