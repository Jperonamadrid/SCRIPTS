#!/bin/bash 
papelera (){
if [ "$1" = "-D" ];then
rm -r ~/papelera/*
fi

if [ "$1" = "-V" ];then
ls ~/papelera
fi

#(Subir nota)
if [ "$1" = "-R" ];then
for mover in $(cat rutas);do
re=$(echo $mover|awk -F"/" '{print $NF}')
mv ~/papelera/$re $mover 
done > rutas
fi
}

#si $1 es igual alguna de estas condiciones ejecutala la funcion
if [ "$1" = "-D" ] || [ "$1" = "-V" ] || [ "$1" = "-R" ];then
papelera ${1}
exit 0
fi


count=0
#ejecutara esto hasta que se acaben los parametros por el shift
until [ -z ${1} ];do 


if [ ! -d ~/papelera ];then
mkdir ~/papelera
fi

#añadimos las rutas para a la hora de restaurar sepa llegar a la ruta
find ~ -name ${1} >> rutas

for ruta in $(find ~ -name ${1});do
mv $ruta ~/papelera/.
#el contador de ficheros movidos
check=$?
if [ $check = "0" ];then
let count=count+1
fi
done
shift
done

echo "Ficheros movidos---->"$count 

