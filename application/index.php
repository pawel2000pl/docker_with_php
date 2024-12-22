<?php

    echo "Hello world";
    echo "<br>";

    $x = 1;
    echo "$x<br>";
    echo "Check setting a breakpoint here<br>"; 
    $x += 1;
    echo "$x<br>";
    echo '<br>';
    echo '<a href="/info.php">info</a>';

    include(Paths::PRIVATE.'example.php');

    echo "<hr>";
    echo file_get_contents("http://127.0.0.1/protected/example.php");
    echo "<hr>";

?>
