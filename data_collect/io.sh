#!/bin/sh

# Collect the first 60 minutes of data, at 30 second intervals, of extended
# I/O data.
echo "IO Statistics (iostat -d ) " > $3/io.txt
echo "iostat -d $1 $2">>$3/io.txt
iostat -d $1 $2 >> $3/io.txt

