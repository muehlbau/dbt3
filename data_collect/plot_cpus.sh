if [ $# -ne 3 ]; then
        echo "Usage: ./plot_cpu.sh <input_dir> <file_name> <output_dir>"
        exit
fi

input_dir=$1
file_name=$2
output_dir=$3

#get the number of files having the name [file_name*]
num_files=`ls $input_dir/$file_name*.csv | wc -l`
echo "$num_files"

let "num_files=$num_files-1"
index=0

OIFS=$IFS 
IFS=","

declare -a TITLE
declare -a VALUE

index=0
#reorganize the files so that they can be used as gnuplot input files
while [ $index -le $num_files ]
do 
	if [ $num_files -eq 0 ]
	then 
		input_file=$input_dir/${file_name}.csv
	else
		input_file=$input_dir/${file_name}${index}.csv
	fi

	echo "reading from $input_dir/${file_name}${index}.csv"
	i=0
	while read -a VALUE
	do
#		echo "the line is ${VALUE[0]}"
		#if it is the first file, get the title
		if [ $i -eq 2 ] && [ $index -eq 0 ]
		then
			j=0
			element_count=${#VALUE[@]}
			while [ $j -lt $element_count ]
			do
				TITLE[$j]=${VALUE[$j]//\//per}
				echo "title is ${TITLE[$j]}"
				let "j=$j+1"
			done
		fi
		if [ $i -gt 2 ]
		then
#			echo ${VALUE[0]}
			j=0
			while [ $j -lt $element_count ]
			do
				let "line_number=$i-2"
				echo "$line_number ${VALUE[$j]}" >> $output_dir/${file_name}${index}_${TITLE[$j]}.data
				let "j=$j+1"
			done
		fi
		let "i=$i+1"
	#done < $input_dir/${file_name}${index}.csv
	done < $input_file
	let "index=$index+1"
done
			
#generate gnuplot scripts for each title
j=0
echo "element count $element_count"
echo "number of files $num_files"
while [ $j -lt $element_count ]
do
	echo -n "plot " > $output_dir/${file_name}_${TITLE[$j]}.input
	index=0
	while [ $index -le $num_files ]
	do
		if [ $index -lt $num_files ]
		then
			echo -n "\"$output_dir/${file_name}${index}_${TITLE[$j]}.data\" with lines, " >>  $output_dir/${file_name}_${TITLE[$j]}.input
		elif [ $index -eq $num_files ]
		then
			echo "\"$output_dir/${file_name}${index}_${TITLE[$j]}.data\" with lines"  >>  $output_dir/${file_name}_${TITLE[$j]}.input
		fi
		let "index=$index+1"
	done
	echo set xlabel '"'60 Second Samples Over Time '"' >> $output_dir/${file_name}_${TITLE[$j]}.input
	echo set ylabel '"'${TITLE[$j]}'"' >> $output_dir/${file_name}_${TITLE[$j]}.input
	echo set term png color >> $output_dir/${file_name}_${TITLE[$j]}.input
	echo set output '"'$output_dir/${file_name}_${TITLE[$j]}.png'"'>> $output_dir/${file_name}_${TITLE[$j]}.input
	echo replot >> $output_dir/${file_name}_${TITLE[$j]}.input
	
#	cd $output_dir
	gnuplot $output_dir/${file_name}_${TITLE[$j]}.input
#	cd ..
	
	let "j=$j+1"
done
