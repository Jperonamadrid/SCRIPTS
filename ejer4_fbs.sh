#!/bin/bash 

#lista los archivos txt para sacar los user
for user in $(ls *.txt);do
name=$(echo $user|cut -d "." -f1)

#comprobar si el user existe
cut -d: -f1 /etc/passwd | grep "$name" > /dev/null 
check=$?


if [ "$check" = "0" ] ; then

	echo "Existe $name"
else
#lo crea
sudo	adduser $name < creador
fi
done


for user in $(ls *.txt);do
#para saber en que directorio meterlo
name=$(echo $user|cut -d "." -f1)
#dentro de cada txt creara los directorios
for archivo in $(cat $user);do

mkdir /home/$name/$archivo
done
done

#elimina los txt



