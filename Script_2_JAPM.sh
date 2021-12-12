
#!/bin/bash
#Directorios=$(find /home/ -maxdepth 1 -type d | cut -c 7-)
usuarios=$(getent passwd {1000..6000} | cut -d: -f1 )
fecha=$(date +"%d-%M-%Y" )
#estos dos comandos hacen cosas diferentes el primero coge todos los nombres que hay en el /home/loquesea / no lo estoy usandolo porque me has dicho que no hace falta comprobarlo
#el comando getent esta cogiendo las uidd de mas de 1000 que seran los usuarios reales del sistema 

function M { 
echo "¿de que usuario quieres ver su tar?" 
select ficheros in $usuarios 
do

tar -ztvf /home/Back_up/backup-"$ficheros"_"$fecha".tar.gz
break 
done

}
# aqui estoy diciendo si dime de que usuario quieres que te haga un listado de su tar 


function l {
ls -t  /home/Back_up/*

}
# esta otra funcion  que lo que hace es simplemente lista todo lo que haya en backup usando -t
# que es una opcion de de ls que lista ordenador por el tiempo y de por si ya coje el mas reciente
#esta estructura es para ver si eres el super usuario que tendra un id 1000  si lo eres hara lo demos si no  te vas a fuera
if [ $(id -u) -eq 0 ]; then
	if [ -d "/home/Back_up" ]; then 
	 echo "EL directorio back up existe"
	 




#elegimos los usuarios que son reales es decir que tienen una uuid de mas de 1000 y les hacemos un select el usuario solo pondra el numero y se creara
# directamente el tar.gz con la fecha y el nombre del mismo 
select hola in $usuarios
do
 
 tar cfz /home/Back_up/backup-"$hola"_"$fecha".tar.gz  /home/$hola
break
done

    

#case para crear el directorio Back_up si no lo tenias

else 
	echo "¿el directorio back up no existe desea crearlo (s/n)?"
		read eleccion

		case "$eleccion" in
			 s | S ) echo  "usted ha escogido si por lo que se creara el directorio"
				mkdir /home/Back_up
 						;;

			 n | N ) echo  "usted ha escogido no por lo que no se creara nada"

 						;;
 			* ) echo  " ha puesto un opción invalida tiene que poner s,S o n,N " ;;
		esac


        fi 
 

else
        echo "solo root puede ejecutar este script "
        exit 2
fi


# estructura de control para ver que has puesto en $1 si es -L hara la funcion l definida arriba si es -M hara la funcion m
if [[ $1 = "-L" ]]; then
l


elif [[ $1 = "-M" ]] ; then 
M
 else
echo "has puesto una opcion no valida" 
fi
