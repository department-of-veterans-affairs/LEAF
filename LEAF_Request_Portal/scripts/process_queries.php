<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$protocol = 'https';
$request_uri = str_replace(['/var/www/html/', '/scripts'], '', $currDir);
$siteRoot = "{$protocol}://" . getenv('HTTP_HOST') . '/' . $request_uri . '/';

$login->setBaseDir('../');
$login->loginUser();
$dir = new Portal\VAMC_Directory;

$form = new Portal\Form($db, $login);

// last process time
$vars = [
    ':lastProcess' => strtotime("30 minutes ago")
    //':lastProcess' => time()
];

$processQueryTotalSQL = 'SELECT id,userID,`url`,lastProcess FROM process_query WHERE lastProcess <= :lastProcess';
$processQueryTotalRes = $db->prepared_query($processQueryTotalSQL, $vars);
// make sure our memory limit did not get reduced, we need to make sure we are not having scripts take it all up.

$email = new Portal\Email();
$email->setSiteRoot($siteRoot);

echo ini_get('memory_limit') . "\r\n";
if (!empty($processQueryTotalRes)) {

    foreach ($processQueryTotalRes as $processQuery) {

        // id for inspection
        echo "Working ID {$processQuery['id']} \r\n";
        // memory check how are we doing on that?
        echo "Memory Usage " . memory_get_usage() . "\r\n";

        // do the processing
        $returnedValue = $form->query($processQuery['url'], true);

        $user = $dir->lookupLogin($processQuery['userID'], true);

        // only notify if we are sending on the first hop, this will be updated somewhat regularly? We need to keep things alive for excel scripts
        if ($processQuery['lastProcess'] == 0) {
            $email->setSubject('Your Process is complete.');
            $email->smartyVariables['emailBody'] = 'Your data has been processed. You can see it <a href="' . $siteRoot . '/api/form/query?q=' . $processQuery['url'] . '">here</a>';
            $emailContent = $email->setContent('LEAF_main_email_template.tpl', 'emailBody', 'Your data has been processed. You can see it <a href="' . $siteRoot . '/api/form/query?q=' . $processQuery['url'] . '">here</a>');
            $email->setBody($emailContent);
            $email->addRecipient($user[0]['email']);
            $didMailSend = $email->sendMail();
            echo "Attempted to send email \r\n";
        }


        // do we have a good run with memory?
        echo "Memory Usage " . memory_get_usage() . "\r\n";
    }
}
