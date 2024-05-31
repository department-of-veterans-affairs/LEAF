<?php

namespace Leaf;


class ErrorNotify
{

    public function __construct()
    {
        
    }

    public function sendNotification(string $title, array $errorsArr){
        
        if(!empty($errorsArr)){
            mail('shane.ottinger@va.gov,jamie.holcomb@va.gov,carrie.hanscom@va.gov,casey.herold@va.gov',$title,var_export($errorsArr,true));
        }
    }
}