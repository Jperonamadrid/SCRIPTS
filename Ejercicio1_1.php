
<?php
print "<pre>"; 
print_r ($_POST);
print "<pre>"; 
?>
// basicamente estoy haciendoles un short  y apartir del foreach de abajo lo decoro un poco y solo le estoy diciendo que me lo ponga desde  los [0]  hasta el [5] ordenado por eso le digo clave  y luego la clave la que seran los numeros los saco por el eco
<?php
$cosas = array($_POST['nombre5'], $_POST['nombr4'], $_POST['nombr3'], $_POST['nombre2'], $_POST['nombre']);
sort($cosas);
foreach ($cosas as $clave => $valor ) {
	echo "nombres[".$clave . " ] = " . $valor . "\n";
}

?>

