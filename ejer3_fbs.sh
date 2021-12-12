#!/bin/bash 

#creacion de grupos con los permisos
for num in {1..3};do
groupadd Grupo$num
mkdir /home/Grupo$num
chmod o-w /home/Grupo$num
chmod o+r /home/Grupo$num
chmod g+rw /home/Grupo$num 
chgrp -R Grupo$num /home/Grupo$num
done

#patron para poder crear usuario
echo -e "c0ntrasena\nc0ntrasena\n\n\n\n\n\nS" > creador

#creación de usuarios
num="0"
count="0"
for user in $(cat usuarios);do
adduser $user < creador
#para añadir los usuarios en diferente grupos cuando cumpla la condicion sumara uno y cambiara de grupo
if [ "$count" = "0" ] || [ "$count" = "4" ] || [ "$count" = "8" ]; then
let num=num+1

fi
let count=count+1
usermod -aG Grupo$num $user
done


