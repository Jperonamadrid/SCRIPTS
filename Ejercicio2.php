<html> 
  <head> 
    <title>Donde se cuenta</title> 
 </head> 
<body> 


<?php
print "<pre>"; 
print_r ($_POST);
print "<pre>"; 
// si no hay nada aqui es que ya le has dado a pincha para incrementar o has puesto 0 
?>

<a href='Ejercicio2_1.php'>  volver hacia atras para meterla otra cantidad </a>
<a href='Ejercicio2.php'>  Pincha aqui para que se incremnte el numero de cookies que has puesto  </a>


  </body> 
</html>



<html> 
    <head> 
        <title>La parte de contar</title> 
   </head>  
  <body> 
<! –– iba a hacerlo en otra pagina aparte lo de las cookies y mostrarlo en otra pero asi es mejor ––>
<?php 

    if (!isset($_COOKIE['contar']))
    {
        ?> 
 
<?php 
        $cookie = 0;
        setcookie("contar", $cookie);
    }
    else
    {
        $cookie = $_POST['numero'] + $_COOKIE['contar'] ;
        setcookie("contar", $cookie);
        ?> 
El numero actual de las cookies es <?= $_COOKIE['contar'] ?>  
<?php  }// termino else  ?> 
   </body> 
</html>

