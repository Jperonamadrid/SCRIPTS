#!/bin/bash
filas=$((RANDOM%30))
columnas=$((RANDOM%30))
for ((i=0; i<$filas; i++ ))
do	
	
	for ((j=0; j<$columnas; j++))
	do
	num=$((RANDOM%99))
	echo -n " $num" 
	done
num1=$((RANDOM%99))
echo $num1


done

