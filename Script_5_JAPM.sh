#!/bin/bash 

listar=$(ls *.txt )
#lista los archivos
for user in $listar; do

nombre=$(echo $user | cut -d "." -f1)

#comprobar si el usuario existe 
cut -d: -f1 /etc/passwd | grep "$nombre" 

check=$?


if [ "$check" = "0" ] ; then

	echo "Existe $nombre"
else
#en el archvo contrasena tiene que estar dos veces puestas la contraseña porque adduser coge dos campos nueva contraseña y repitelo 
#y luego hace falta poner s en miniscula que es lo ultimo que pide para confirmar toodo 
	adduser $nombre < contrasena  
fi
done



