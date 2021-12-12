#!/bin/bash 

#encontrar ficheros vacios
find $HOME -type d -empty 

#preguntamos si queremos borrarlos
read -p "¿Quieres eliminarlos--(si/no)-->?" check
if [ "$check" = "si" ];then
	for directorios in  $(find $HOME -type d -empty);do
	rm -r $directorios 2>/dev/null
	done
else 
#En caso de no decir si nos imprimira esto
echo "No los has borrado"
fi
