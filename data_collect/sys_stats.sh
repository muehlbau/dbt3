#!/bin/sh
if [ $# -ne 4 ]; then
	echo "Usage: ./collect_data.sh <interval> <duration> <cpus> <result_dir>"
	exit
fi

INTERVAL=$1
RUN_DURATION=$2
CPUS=$3
RESULTS_PATH=$4

#calculate count
let "COUNT=$RUN_DURATION/$INTERVAL"
if [ $COUNT -eq 0 ]
then
	COUNT=1
fi

#get one more count
let "COUNT=$COUNT+1"

##get database statistics
echo "start db_stats.sh"
./db_stats.sh $SID $RESULTS_PATH $COUNT $INTERVAL &
#
if [ -f ./run.sar.data ]; then
	rm ./run.sar.data
fi

echo "start sar"
VERSION=`uname -r | awk -F "." '{print $2}'`

if [ $VERSION -eq 5 ]
then 
#use sysstat 4.1.1
/usr/local/bin/sar -u -U ALL -d -B -r -q -W -b -o run.sar.data $INTERVAL $COUNT &
else
#use sysstat 4.0.3
/usr/bin/sar -u -U ALL -d -B -r -q -W -b -o run.sar.data $INTERVAL $COUNT &
fi

echo "start iostat"
sh ./io.sh $INTERVAL $COUNT $RESULTS_PATH &
# collect vmstat 
echo "start vmstat"
echo "vmstat $INTERVAL $COUNT" > $RESULTS_PATH/vmstat.out
vmstat $INTERVAL $COUNT >> $RESULTS_PATH/vmstat.out &
#sh ./runtop.sh $1 $2 $RESULTS_PATH &

echo "sleep for $RUN_DURATION seconds..."
sleep $RUN_DURATION
echo "sys_stats.sh done"

#getprof
#echo "get cpu info"
#echo "cpu is $CPUS"
#echo "Cpu Statistics (sar -u  $INTERVAL $COUNT) ">$RESULTS_PATH/all.cpu.txt
#echo `uname -a `>>$RESULTS_PATH/all.cpu.txt
#sar -u -f ./run.sar.data >> $RESULTS_PATH/all.cpu.txt

#reformatting the cpu data files
#i=0
#while [ "$i" -lt "$CPUS" ]
#do 
#	echo "reformatting cpu$i"
#	sleep 2
#	echo "CPU Statistics CPU$i (sar -u $INTERVAL $COUNT)" > $RESULTS_PATH/cpu$i.csv
#	echo `uname -a` >> $RESULTS_PATH/cpu$i.csv
#	echo "%user,%nice,%system,%idle">>$RESULTS_PATH/cpu$i.csv
#        sar -u -U ALL -f ./run.sar.data | awk '{ if (NR>2) { if ($1!="Average:" && $3=="'$i'") { print $4","$5","$6","$7;} else { if ($1=="Average:" && $2=="'$i'") { print $3","$4","$5","$6;}}}}'>>$RESULTS_PATH/cpu$i.csv
#	i=$(($i+1))
#done

#reformatting the io data files
#echo "reformatting io data files"
#for i in `iostat | egrep '^dev' | awk '{print $1}'`
#do
#        echo "Disk IO (iostat -d  $INTERVAL $COUNT) " > $RESULTS_PATH/$i.csv
#        echo `uname -a` >>$RESULTS_PATH/$i.csv
#        echo "tps,blk_read/s,blk_wrtn/s,blk_read,blk_wrtn" >>$RESULTS_PATH/$i.csv
#        cat $RESULTS_PATH/io.txt| grep "$i " | awk '{ print $2","$3","$4","$5","$6}' >>$RESULTS_PATH/$i.csv
#done

#reformatting the paging data files
echo "reformatting paging data files"
echo "Paging (sar -B  $INTERVAL $COUNT) " > $RESULTS_PATH/paging.txt
echo "Paging (sar -B  $INTERVAL $COUNT) " > $RESULTS_PATH/paging.csv
echo `uname -a` >>$RESULTS_PATH/paging.txt
echo `uname -a` >>$RESULTS_PATH/paging.csv
sar -B -f ./run.sar.data | tee -a $RESULTS_PATH/paging.txt | awk '{ if (NR>2) { if ($1!="Average:") print $3","$4","$5","$6","$7","$8; else { print $2","$3","$4","$5","$6","$7};}}'>>$RESULTS_PATH/paging.csv

#reformatting the memory data files
#echo "reformatting memory data files"
#echo "Memory (sar -r  $INTERVAL $COUNT) "  > $RESULTS_PATH/memory.txt
#echo "Memory (sar -r  $INTERVAL $COUNT) "  > $RESULTS_PATH/memory.csv
#echo `uname -a` >>$RESULTS_PATH/memory.txt
#echo `uname -a` >>$RESULTS_PATH/memory.csv
#sar -r -f ./run.sar.data | tee -a $RESULTS_PATH/memory.txt | awk '{ if (NR>2) { if ($1!="Average:") print $3","$4","$5","$6","$7","$8","$9","$10","$11; else { print $2","$3","$4","$5","$6","$7","$8","$9","$10};}}'>>$RESULTS_PATH/memory.csv
#
##reformatting the processor queue data files
#echo "reformatting queue data files"
#echo "Load (sar -q  $INTERVAL $COUNT) "  > $RESULTS_PATH/queue.txt
#echo "Load (sar -q  $INTERVAL $COUNT) "  > $RESULTS_PATH/queue.csv
#echo `uname -a` >>$RESULTS_PATH/queue.txt
#echo `uname -a` >>$RESULTS_PATH/queue.csv
#sar -q -f ./run.sar.data | tee -a $RESULTS_PATH/queue.txt | awk '{ if (NR>2) { if ($1!="Average:") { print $3","$4","$5","$6;} else { print $2","$3","$4","$5;}}}'>>$RESULTS_PATH/queue.csv
#
##reformatting the processor queue data files
#echo "reformatting swap data files"
#echo "Swap (sar -W  $INTERVAL $COUNT)" >$RESULTS_PATH/swap.txt
#echo "Swap (sar -W  $INTERVAL $COUNT)" >$RESULTS_PATH/swap.csv
#echo `uname -a` >>$RESULTS_PATH/swap.txt
#echo `uname -a` >>$RESULTS_PATH/swap.csv
#sar -W -f ./run.sar.data | tee -a $RESULTS_PATH/swap.txt | awk '{ if (NR>2) { if ($1!="Average:") {print $3","$4;} else { print $2","$3;}}}'>>$RESULTS_PATH/swap.csv
#
