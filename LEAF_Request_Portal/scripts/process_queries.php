<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
error_reporting(E_ALL ^ E_WARNING);

$currDir = dirname(__FILE__);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$protocol = 'https';
$request_uri = str_replace(['/var/www/html/', '/scripts'], '', $currDir);
$siteRoot = "{$protocol}://" . getenv('APP_HTTP_HOST') . '/' . $request_uri . '/';

$login->setBaseDir('../');

$dir = new Portal\VAMC_Directory;



// last process time, we may want to impliment a refresh more often than the daily it is now.
$vars = [
    ':lastProcess' => strtotime("30 minutes ago")
    //':lastProcess' => time()
];

$processQueryTotalSQL = 'SELECT id,userID,`url`,lastProcess FROM process_query';
$processQueryTotalRes = $db->query($processQueryTotalSQL);
// make sure our memory limit did not get reduced, we need to make sure we are not having scripts take it all up.

echo ini_get('memory_limit') . "\r\n";
if (!empty($processQueryTotalRes)) {

    foreach ($processQueryTotalRes as $processQuery) {

        // similar logic used for the directory in the form, probably want to do cleanup here. not sure of options at this time.
        $directory = __DIR__ . '/../files/temp/processedQuery/';
        $currentFileName = $directory . $processQuery['id'] . '_' . $processQuery['userID'] . '.json';

        // looking at skipping ones that are created already, maybe look at time as well? Not sure how I would want to handle that
        if (is_file($currentFileName)) {
            echo "Skipping file creation due to file existing already.\r\n";
            continue;
        }

        // id for inspection
        echo "Working ID {$processQuery['id']} \r\n";
        // memory check how are we doing on that?
        echo "Memory Usage " . memory_get_usage() . "\r\n";

        $login->loginUser($processQuery['userID']);
        $form = new Portal\Form($db, $login);
        // do the processing
        $returnedValue = $form->query($processQuery['url'], true);

        $user = $dir->lookupLogin($processQuery['userID'], true);

        // only notify if we are sending on the first hop, this will be updated somewhat regularly? We need to keep things alive for excel scripts
        if ($processQuery['lastProcess'] == 0) {

            $email = new Portal\Email();
            $email->setSiteRoot($siteRoot);
            $email->setSubject('Your Process is complete.');
            $emailContent = 'Your data has been processed. You can see it <a href="' . $siteRoot . '/api/form/query?q=' . $processQuery['url'] . '">here</a><br><br><br><br>';
            $email->setBody($emailContent);
            $email->addRecipient($user[0]['email']);
            $didMailSend = $email->sendMail();
            unset($email);
            echo "Attempted to send email \r\n";
        }

        unset($form);
        // do we have a good run with memory?
        echo "Memory Usage " . memory_get_usage() . "\r\n";
    }
}
