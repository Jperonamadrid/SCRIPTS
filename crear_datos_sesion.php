<?php session_start(); 

$_SESSION['email']=$_POST['email'];
$_SESSION['nombre']=$_POST['nombre'];
header("Location:inicio.php");
?>