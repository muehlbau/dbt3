#!/bin/sh

# Collect the first 60 minutes of data, at 30 second intervals, of extended
# I/O data.
echo "IO Statistics (iostat -d ) " > $3/io.txt
echo "iostat -d $1 $2">>$3/io.txt
VERSION=`uname -r | awk -F "." '{print $2}'`

if [ $VERSION -eq 5 ]
then
#use sysstat 4.1.1
/usr/local/bin/iostat -d $1 $2 >> $3/io.txt
else
#use sysstat 4.0.3
/usr/bin/iostat -d $1 $2 >> $3/io.txt
fi
