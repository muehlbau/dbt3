#
# string_to_number.sh
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2003 Open Source Development Lab, Inc.
#
#
#!/bin/sh
#convert string time to number of seconds
#if DATE_TIME_FORMAT is set to internal, timediff() returns a value in 
# hhhhmmss. This is strange, but I have to convert it to seconds

if [ $# -ne 1 ]; then
        echo "Usage: ./string_to_number.sh <string>"
        exit
fi

string=$1
index=7
number=0
base=1
while [ "$index" -gt 0 ]
do
let "index2=$index-1"
if [ "${string:$index2:1}" == 0 ] 
then
	let "number = ${string:$index:1}* ${base} + $number"
else
	let "number = ${string:$index2:2}* ${base} + $number"
fi

let "index = $index - 2"
let "base = base*60"
done

echo $number
