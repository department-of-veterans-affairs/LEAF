<?php

namespace App\Leaf;


class ErrorNotify
{

    public function __construct()
    {
        
    }

    public function sendNotification(string $title, array $errorsArr){
        if(!empty($errorsArr)){
            mail('shane.ottinger@va.gov',$title,var_export($errorsArr));
        }
    }
}