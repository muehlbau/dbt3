# Input directories to compare
#DIR1=db_stat_279812/plan
#DIR2=db_stat_279810/plan

DIR1=$1
DIR2=$2

echo Comparing $DIR1 with $DIR2
CNT=0
MATRIX=""
COLUMN="  1  2  3  4  5  6  7  8  9 10 11 12 13 14 16 17 18 19 20 21 22"
echo  " Power Test queries O (same)   X (different)  "
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22
do
sed 's/(cost=.*//' $DIR1/power_query$i.txt > /tmp/power_plan1_$i
sed 's/(cost=.*//' $DIR2/power_query$i.txt > /tmp/power_plan2_$i
COUNT=`diff /tmp/power_plan1_$i /tmp/power_plan2_$i |wc -l `
#echo QUERY $i Difference  $COUNT lines

if [ $COUNT -eq 0 ]
#       the same plan	
then MATRIX="${MATRIX}  O"
     (( CNT= $CNT + 1 ))
else
#       not the same plan	
   MATRIX="${MATRIX}  X"
fi

done


echo  "$COLUMN"
echo  "$MATRIX"

echo " Throughput Test queries  O (same)   X (different)    < > or <> no plan available "

MATRIX=""
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22
do
# check that files are not empty before comparing
SIZE1=`ls --size  $DIR1/throughput_stream1_query$i.txt | awk '{print $1}'`
SIZE2=`ls --size  $DIR2/throughput_stream1_query$i.txt | awk '{print $1}'`

STRING=""

if [ $SIZE1 -eq 0 ]
then
STRING="<"
fi
if [ $SIZE2  -eq 0 ]
then
STRING="${STRING}>"
else STRING="${STRING} "
fi
(( EMPTY = $SIZE1 * $SIZE2 ))
if [ $EMPTY -eq 0 ]
then
# echo  QUERY $i  ${STRING} FILE is empty
  if [ $SIZE1 -eq 0 ]
  then 
	EMPTY_STG=" < " 
	if [ $SIZE2  -eq 0 ]
	then
	   EMPTY_STG=" <>"
        fi
  else
	if [ $SIZE2  -eq 0 ]
        then
           EMPTY_STG=" > "
	else
	# This better not happen 
	   EMPTY_STG=""
	fi
  fi
MATRIX="${MATRIX}${EMPTY_STG}"
else
  sed 's/(cost=.*//' $DIR1/throughput_stream1_query$i.txt > /tmp/thru_plan1_$i
  sed 's/(cost=.*//' $DIR2/throughput_stream1_query$i.txt > /tmp/thru_plan2_$i
  COUNT=`diff /tmp/thru_plan1_$i /tmp/thru_plan2_$i |wc -l `
#  echo QUERY $i Difference  $COUNT lines
#
  if [ $COUNT -eq 0 ]
#       the same plan   
  then MATRIX="${MATRIX}  O"
     (( CNT= $CNT + 1 ))
  else
#       not the same plan       
   MATRIX="${MATRIX}  X"
fi

fi

done
echo  "$COLUMN"
echo  "$MATRIX"

