<?php session_start(); ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Autenticación</title>
</head>
<body>
<h1></h1>
<?php
    if(!isset($_SESSION['email'])){
        echo "Al no haber valores iniciales de SESSION, cargo el formulario de peticion de datos";
        include "formulario.php";
    }else{
        echo "<h2>Hola : " . $_SESSION['nombre'] . "</h2>";
        echo "Ya estás identificado en el sistema";
        $_SESSION['auth'] = true;
        ?>
        <a href="sesion.php">Siguiente pagina para ver el resto de datos</a>
        <?php
    }
?>
</body>
</html>
