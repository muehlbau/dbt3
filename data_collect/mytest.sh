#!/bin/sh

size=320
width=1
colour='-color black'
usage="usage: $0 [-s N] [-w N] [-c S] imagefile..."

while getopts ":s:w:c:" opt; do
	case $opt in
	s) size=$OPTARG ;;
	w) width=$OPTARG ;;
	c) colour="-color $OPTARG" ;;
	\?) echo $usage
		exit 1 ;;
	esac
done

echo "size $size width $width color $colour"
