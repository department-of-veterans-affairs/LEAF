<?php
var_dump($argv);
if(!empty($argv[1])){
    var_dump(json_decode($argv[1]));
}
echo time()."Moo\r\n";
sleep(30);
echo time()."EndMoo\r\n";