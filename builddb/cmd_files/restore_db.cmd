util_connect dbm,dbm
util_execute INIT CONFIG
recover_start data
recover_start incr
util_release
