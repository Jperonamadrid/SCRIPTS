#!/bin/bash 

#asginamos el tamaño de la matriz
b=$(($RANDOM%30))
z=$(($RANDOM%30))

#aqui sacamos el número de veces que vamos a repetir el bucle
let c=$b*$z

#le asginamos el valor del número aleatorio
d=$b
r=$z

echo ------------
echo "Matriz  "$b"x"$z
  
for ((a=1 ;a <= $c;a++ ));do


random=$(($RANDOM%99))

#este if es para el tema de los espacios para numero menores de 10
if [ "$random" -lt "10" ];then
echo -n  "$random  "
else
echo -n  "$random "
fi

#cuando la variable que hay en for sea $a sea igual $d creala la siguiente fila
if [ "$a" = "$d" ];then
echo
#aqui se ejecutara la siguiente linea
let d=d+b
fi


done 



for ((j=1 ;j <= $c;j++ ));do



if [ "$a" = "$z" ];then
echo
#aqui se ejecutara la siguiente linea
let r=r+z
fi


done


