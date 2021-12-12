#!/bin/bash
counter=0 

# defino primero la funcion que genera los numeros aleatorios
function numericos () {
random=$(( $RANDOM%999 ))
 echo "$(llamando)" 


}
# aqui creo una funcion para recoger todos los echos de las funciones de rangos 
function llamando () {
echo -n " $(rang1)"
echo -n "$(rang2) "
echo -n "$(rang3) "
echo -n "$(rang4) "
echo -n "$(rang5)"
echo -n "$(rang6)"
echo -n "$(rang7)"
echo -n "$(rang8)"
echo -n "$(rang9) "
echo -n  "$(rang10)   "
let countador=countador+1
countador=0

}
# aqui empiezo a definir las funciones son iguales todas excepto la primeora porque es de 0 a 99 es decir si es menor que 99  te lo dira
function rang1 ()
{
 if [[  $random -lt 99 ]]  ; then

echo " $random esta en el rango 0 a 99"

fi
}


function rang2 ()
{
 if [[  $random -gt 99 ]] && [[ $random -lt 199 ]]  ; then
echo "$random esta en el rango 99 a 199 "

fi
}


function rang3 ()
{
 if [[  $random -gt 199 ]] && [[ $random -lt 299 ]]  ; then
echo "$random esta en el rango 199 y 299"
 
    
fi
}

function rang4 ()
{
 if [[  $random -gt 299 ]] && [[ $random -lt 399 ]]  ; then
echo " $random esta en el rango 299 y 399"
       
fi
}

function rang5 ()
{
 if [[  $random -gt 399 ]] && [[ $random -lt 499 ]]  ; then
echo " $random esta en el rango 399 y 499"
  
         
fi
}

function rang6 ()
{
 if [[  $random -gt 499 ]] && [[ $random -lt 599 ]]  ; then
echo " $random  esta en el rango 499 y 599"
  
         
fi
}

function rang7 ()
{
 if [[  $random -gt 599 ]] && [[ $random -lt 699 ]]  ; then
echo " $random esta en el rango 599 y 699"
  
         
fi
}

function rang8 ()
{
 if [[  $random -gt 699 ]] && [[ $random -lt 799 ]]  ; then
echo "$random esta en el rango 699 y 799"
  
       
fi
}

function rang9 ()
{
 if [[  $random -gt 799 ]] && [[ $random -lt 899 ]]  ; then
echo "$random esta en el rango 799 y 899"
  
        
fi
}

function rang10 ()
{
 if [[  $random -gt 899 ]] && [[ $random -lt 999 ]]  ; then
echo "$random esta en el rango 899 y 999"
	
       
fi
}



#aqui le pido al usuario el numero de veces que quiere hacer el numero aleatorio que asi vez imprimira por pantalla el rango al que pertence 
echo "cuantos numeros necesitas generar" 
read numeros
#loop para repetir el numero de veces que sea lo que diga el usuario

for ((n=0;n<numeros;n++)); do

    numericos; 
done
