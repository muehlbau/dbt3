echo "recover db"
_o=`cat <<EOF | dbmcli -d DBT3 -u dbm,dbm 2>&1
db_cold
util_connect
util_execute INIT CONFIG
recover_start data
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "db recover failed: $_o"
        exit 1
fi

echo "back up database"
./backup_db.sh
