<?php
$emailRegex = "/(\w+@[a-z_\-]+?\.[a-z]{2,6})$/i";

$email = "David.Arzouman@va.gov";

var_dump(preg_match($emailRegex,$email));