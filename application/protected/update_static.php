<?php 
    file_put_contents(Paths::PROTECTED.'/static.txt', 'static protected file<br>Modified by cron script '.strval(time()));
?>
