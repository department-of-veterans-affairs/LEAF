<?php

$data = file_get_contents('/var/www/log/time_to_evolve.txt');
$replace = file_get_contents('/var/www/log/replacement.txt');
$list = json_decode($data, true);

foreach ($list as $value) {
    // need to open the file to be modified
    $file_data = file_get_contents($value['file_name']);
    // modify the file
    $file_data = str_replace($value['string'], $replace, $file_data);
    // save the file
    file_put_contents($value['file_name'], $file_data);
}
