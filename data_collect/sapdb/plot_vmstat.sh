RUNS='q1 q2'
#RUNS='285 286 287 288 289 290 291 292 293 294 295'
#RUNS='296 297 298 299 300 301 302 303 304 305 306'
#RUNS='316 317 318 319 320 321 322 323 324 325'
FILE=vmstat.out
OUTDIR=./tmp
#OUTDIR=./noncached_2.4_vmstat_runs285_295
#OUTDIR=./cached_2.4_vmstat_runs296_306
#OUTDIR=./cached_2.5_vmstat_runs316_325

declare -a STAT=(r b w swpd free buff cache si so bi bo In cs us sy id)
ptrS=0 	#pointer to STAT array and column of data
EGREPSTRG="cache|procs"

for ptrS in   0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 
do
	first_one=0
        echo Doing Stats for ${STAT[$ptrS]}
	for R in $RUNS
	do
        (( COLUMN = $ptrS + 1  ))    #adjust for leading space
	echo "{print $"$COLUMN"}" > awkin
egrep -v $EGREPSTRG  $R/$FILE | awk -f awkin | nl |sed "s/    //"  > ${OUTDIR}/${STAT[$ptrS]}_run$R
        if [ $first_one -lt 1 ]
	then
		(( first_one = $first_one + 1 ))
		STRING="plot "
	else
		STRING="${STRING},"
		echo "," >> ${OUTDIR}/bt_${STAT[$ptrS]}_input
	fi
	STRING="${STRING} \"${STAT[$ptrS]}_run$R\" with lines"
#	echo plot '"'${STAT[$ptrS]}_run$R'"' with lines  >> ${OUTDIR}/bt_${STAT[$ptrS]}_input
	done

echo $STRING > ${OUTDIR}/bt_${STAT[$ptrS]}_input
#cat ${OUTDIR}/bt_${STAT[$ptrS]}_input | xargs > ${OUTDIR}/bt_${STAT[$ptrS]}_input

echo set xlabel '"'60 Second Samples Over Time '"' >> ${OUTDIR}/bt_${STAT[$ptrS]}_input

echo set ylabel '"' vmstat column ${STAT[$ptrS] }'"' >> ${OUTDIR}/bt_${STAT[$ptrS]}_input

echo set term png color >> ${OUTDIR}/bt_${STAT[$ptrS]}_input

echo set output '"'bt_${STAT[$ptrS]}.png'"' >> ${OUTDIR}/bt_${STAT[$ptrS]}_input

echo replot >> ${OUTDIR}/bt_${STAT[$ptrS]}_input

cd ${OUTDIR}
gnuplot bt_${STAT[$ptrS]}_input
cd ..
 
done
  
