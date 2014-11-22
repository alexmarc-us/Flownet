#!/bin/bash

array=( zero one two three four )

len=${#array[*]}
echo "The array has $len members. They are:"
i=0
while [ $i -lt $len ]; do
	echo "$i: ${array[$i]}"
	let i++
done


n=1
while [ $n -lt 6 ]; do
	let n++
	echo "$n"
done

