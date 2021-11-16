#!/bin/bash
sudo groupadd asir2
chgrp asir2 /home/asir2
chmod g+rwx  /home/asir2

function usuarios 
{
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
	     sudo usermod -a -G asir2 $usuario	
		
		[ $? -eq 0 ] && echo "se ha añadido $usuario" || echo "error al añadir $usuario"
	fi
else
	echo "solo root puede ejecutar este comando"
	exit 2
fi
}


for ((n=0;n<5;n++)); do
    usuarios; 
done

