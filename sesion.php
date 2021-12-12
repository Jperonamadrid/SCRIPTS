<?php session_start(); ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Ejemplo de Sesiones</title>
</head>
<body>
<?php
    if($_SESSION['auth']){
        echo "Este es tu email:".$_SESSION['email']." ------- este es tu nombre: ".$_SESSION['nombre'];
        
        ?>
        <a href="logout.php">Salir</a>
        <?php
    }else{
        echo "No estás autenticado<br>";
        ?>
	<p> </p> 
        <a href="inicio.php">Salir</a>
        <?php
    }
?>
</body>
</html>
