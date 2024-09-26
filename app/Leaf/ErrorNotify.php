<?php

namespace App\Leaf;


class ErrorNotify
{

    /**
     * This is the basic function we are going to start with for getting notifications of errors to devs, we will want to move this over
     * to dynatrace eventually.
     * @param string $title
     * @param array $errorsArr
     */
    public function sendNotification(string $title, array $errorsArr): void
    {
        if(!empty($errorsArr)){
            mail('noname@email.com',$title,var_export($errorsArr,true));
        }
    }

    public function logEmailErrors(array $errorsArr): void
    {
        if(!empty($errorsArr)){
            error_log(print_r($errorsArr, true), 3, '/var/www/php-logs/email_errors.log');
        }
    }

    public function logEmailNotices(array $noticeArr): void
    {
        if(!empty($noticeArr)){
            error_log(print_r($noticeArr, true), 3, '/var/www/php-logs/email_notices.log');
        }
    }
}