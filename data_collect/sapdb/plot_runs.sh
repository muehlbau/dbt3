#!/bin/sh

#if [ $# -ne 2 ]; then
#        echo "Usage: ./plot_runs.sh <output_dir> <interval>"
#        exit
#fi

index=1
while [ $index -le 22 ]
do
	echo "processing q$index"
	if [ -d q$index/plot ]
	then
		rm -rf q$index/plot
	fi
	mkdir -p q$index/plot
	for i in cpu memory dev8-
	do
		./plot_cpus.sh q$index $i q$index/plot
	done
	let "index=$index+1"
done

echo "processing power"
mkdir -p power/plot
rm power/plot/*
for i in cpu memory dev8-
do
	./plot_cpus.sh power $i power/plot
done

