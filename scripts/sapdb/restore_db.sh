echo "recover db"
_o=`cat <<EOF | dbmcli -d $SID -u dbm,dbm 2>&1
db_cold
util_connect dbm,dbm
util_execute INIT CONFIG
recover_start data
recover_start incr
util_release
quit
EOF`
_test=`echo $_o | grep OK`
if [ "$_test" = "" ]; then
        echo "db recover failed: $_o"
        exit 1
fi
