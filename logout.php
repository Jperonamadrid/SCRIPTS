<?php session_start(); ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Salida</title>
</head>
<body>
<?php
    echo "Has salido del sistema (haces el destroy)";
    session_destroy();
    ?>
    <a href="sesion.php"> volver a ver la sesion</a>
    <br>
    <p>
    <a href="inicio.php"> volver al inicio inicio</a>
    </p> 
    <?php


?>
</body>
</html>
