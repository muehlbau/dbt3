#/bin/sh

#This script goes to the result direcotry, find the number of files having
#the file name [name*], calculate diff, and operations/sec

if [ $# -ne 3 ]; then
        echo "Usage: ./analyze_dbmon_out.sh <output_dir> <file_name> <interval>"
        exit
fi

output_dir=$1
file_name=$2
interval=$3

#get the number of files having the name [file_name*]
num_files=`ls $output_dir/$file_name*.out | wc -l`
#echo "$num_files"

let "num_files=$num_files-1"
index=0

OIFS=$IFS; IFS=";"		#sapdb monitor output use ";" for field separator
declare -a name
declare -a value1
declare -a value2
declare -a diff
declare -a sum_diff

while [ $index -lt $num_files ]
do
	echo "reading from $output_dir/$file_name$index.out"
	i=0
	while read names values
	do
		#echo "the line read $var1"
		#if [ "$name" != OK && "$value" != END ] 
		#echo "name is $names"
		if [ "$names" != OK ] && [ "${names:0:3}" != END ]
		then
			name[$i]=$names
			value1[$i]=$values
			#echo "name is ${name[$i]} value1 is ${value1[$i]}"
			let "i=$i+1"
		fi
	done < $output_dir/$file_name$index.out
	let "index=$index+1"
	echo "reading from $output_dir/$file_name$index.out"
	i=0
	while read names values
	do
		#echo "the line read $var1"
		#if [ "$name" != OK && "$value" != END ] 
		#echo "name is $name"
		if [ "$names" != OK ] && [ "${names:0:3}" != END ]
		then
			value2[$i]=$values
			#echo "name is ${name[$i]} value2 is ${value2[$i]}"
			let "i=$i+1"
		fi
	done < $output_dir/$file_name$index.out
	element_count=${#name[@]}
	#initialize sum_diff
	if [ $index -eq 1 ]
	then
		i=0
		while [ $i -lt $element_count ]
		do
			sum_diff[$i]=0
			let "i=$i+1"
		done
	fi	
	#calculate the difference
	i=0
	while [ $i -lt $element_count ]
	do
		#echo "value2 ${value2[$i]} value1 ${value1[$i]}"
		let "tt = ${value2[$i]}-${value1[$i]}"
		diff[$i]=$tt
		let "tt=${diff[$i]}+${sum_diff[$i]}"
		sum_diff[$i]=$tt
		echo "${name[$i]} diff is ${diff[$i]}"
		let "i=$i+1"
	done
	echo "======================="
done

i=0
while [ $i -lt $element_count ]
do
	avg_per_sec=`echo ${sum_diff[$i]}/${num_files}/${interval} | bc -l`
#	bc <<END-OF-INPUT
#	scale=2
#	${sum_diff[$i]}/($num_files)/$interval 
#	END-OF-INPUT

	echo "${name[$i]} sum_diff is ${sum_diff[$i]} avg_per_sec $avg_per_sec"
	let "i=$i+1"
done

IFS=$OIFS
