#!/bin/bash

contrasena="1"
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " usuario
#read -s -p Enter password :  contrasena
	egrep "^$usuario" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$usuario existe"
		exit 1
	else
           pass=$(perl -e 'print crypt($ARGV[0], "contrasena")' $contrasena) 
	   sudo useradd -m -s /bin/bash -p  "$pass" "$usuario"
	    sudo chmod a+x  /$(pwd)
		[ $? -eq 0 ] && echo "se ha añadido $usuario" || echo "error al añadir $usuario"
	fi
else
	echo "solo root puede ejecutar este comando"
	exit 2
fi
