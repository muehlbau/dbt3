#!/bin/sh

s_time=`date +%H%M%S`
sleep 3
e_time=`date +%H%M%S`
let "time_diff=e_time-s_time"

echo $s_time
echo $e_time
echo $time_diff
