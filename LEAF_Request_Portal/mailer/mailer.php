<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Mailer process for asynchronous email
    Date Created: February 15, 2012

*/

use App\Leaf\XSSHelpers;

set_time_limit(10);
$currDir = dirname(__FILE__);
require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$errorNotify = new App\Leaf\ErrorNotify();

// Mail queue folder
$folder = $currDir . '/../templates_c/mailer/';
$file = '';
$webMode = false;
$webLog = array();

if (isset($argv[1])) {
    $file = XSSHelpers::scrubFilename($argv[1]);
} else {
    $webMode = true;
}

clearstatcache();

if (strlen($file) == 40) {
    if (file_exists($folder . $file)) {
        $email = unserialize(file_get_contents($folder . $file));

        if (mail($email['recipient'], $email['subject'], $email['body'], $email['headers'])) {
            unlink($folder . $file);
        } else {
            $errorNotify->logEmailNotices(array('notice: ' => 'Mail queued:',
                                                'subject: ' => $email['subject']));
            //trigger_error('Mail queued: ' . $email['subject']); // do we really need this any longer? It just clutters up the log file
        }
    }
}

$queue = scandir($folder);

foreach ($queue as $item) {
    if (strlen($item) == 40) {
        // attempt to resend email if its 5 minutes old
        if (file_exists($folder . $item) && time() - filemtime($folder . $item) >= 300) {
            $email = unserialize(file_get_contents($folder . $item));

            if (strlen(trim($email['recipient'])) == 0) {
                // delete invalid cache
                unlink($folder . $item);

                $errorNotify->logEmailErrors(array('error: ' => 'Mail no recipient:',
                                                'subject: ' => $email['subject']));
                //trigger_error('Mail no recipient: ' . $email['subject']);
            } else {
                touch($folder . $item);    // reset timer

                if (mail($email['recipient'], $email['subject'], $email['body'], $email['headers'])) {
                    unlink($folder . $item);
                    $errorNotify->logEmailNotices(array('notice: ' => 'Queued mail sent:',
                                                'subject: ' => $email['subject']));
                    //trigger_error('Queued mail sent: ' . $email['subject']); // do we really need this any longer? It just clutters up the log file

                    if ($webMode) {
                        $webLog[] = "Sent {$email['subject']} to {$email['recipient']}";
                    }
                } else {
                    $errorNotify->logEmailErrors(array('error: ' => 'Mail queued again:',
                                                'subject: ' => $email['subject']));
                    //trigger_error('Mail queued again: ' . $email['subject']);
                }
            }
        }
    }
}

if ($webMode) {
    print_r($webLog);
    echo '<br />Done.';
}
