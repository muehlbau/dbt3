#!/bin/sh

if [ $# -ne 1 ]; then
        echo "Usage: ./string_to_number.sh <string>"
        exit
fi

string=$1
index=0
number=0
while [ "$index" -le 7 ]
do
let "index2=$index+1"
base=1
while [ "$index2" -le 7 ]
do
	let "base = $base * 10"
	let "index2 = $index2 + 1"
done 
let "number = ${string:$index:1}* ${base} + $number"
let "index = $index + 1"
done

echo $number
