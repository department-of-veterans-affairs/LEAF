<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
// this file will need to be added, Pete's destruction ticket has it already.

$currDir = dirname(__FILE__);
require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$protocol = 'https';
$db->query("SET SESSION MAX_EXECUTION_TIME=0;");   
$request_uri = str_replace(['/var/www/html/','/scripts'],'',$currDir);

$siteRoot = "{$protocol}://" . HTTP_HOST . '/' . $request_uri . '/';

$dir = new Portal\VAMC_Directory;



// last process time, we may want to impliment a refresh more often than the daily it is now.
$vars = [
    ':lastProcess' => strtotime("30 minutes ago")
    //':lastProcess' => time()
];
$db->checkLargeQueries = false;
$processQueryTotalSQL = 'SELECT id,userID,`sql`,`data`,lastProcess FROM process_query';
$processQueryTotalRes = $db->query($processQueryTotalSQL);
// make sure our memory limit did not get reduced, we need to make sure we are not having scripts take it all up.

if (!empty($processQueryTotalRes)) {

    foreach ($processQueryTotalRes as $processQuery) {

        // similar logic used for the directory in the form, probably want to do cleanup here. not sure of options at this time.
        $directory = __DIR__ . '/../files/temp/processedQuery/';
        if(!is_dir($directory)){
            mkdir($directory);
        }
        $currentFileName = $directory . $processQuery['id'] . '_' . $processQuery['userID'] . '.json';
        // looking at skipping ones that are created already, maybe look at time as well? Not sure how I would want to handle that
        if (is_file($currentFileName)) {
            echo "Skipping file creation due to file existing already.\r\n";
            continue;
        }

        // do the processing
        $data = $db->prepared_query($processQuery['sql'], json_decode($processQuery['data'],true));
        file_put_contents($currentFileName, json_encode($data));


        // update the timestamp
        $sqlUpdate = "UPDATE process_query SET lastProcess = :lastProcess WHERE id = :id";
        $varUpdate = [':lastProcess' => time(), ':id' => $processQuery['id']];
        $db->prepared_query($sqlUpdate, $varUpdate);

        // only notify if we are sending on the first hop, this will be updated somewhat regularly? We need to keep things alive for excel scripts
        if ($processQuery['lastProcess'] == 0) {
            $user = $dir->lookupLogin($processQuery['userID'], true);

            $email = new Portal\Email();
            $email->setSiteRoot($siteRoot);
            $email->setSubject('Your Process is complete.');
            $emailContent = 'Your data has been processed. You can see it <a href="' . $siteRoot . '/api/form/query?q=' . $processQuery['url'] . '">here</a><br><br><br><br>';
            $email->setBody($emailContent);
            $email->addRecipient($user[0]['email']);
            $didMailSend = $email->sendMail();
            unset($email);
        }

        // do we have a good run with memory?
        echo "Memory Usage " . memory_get_usage() . "\r\n";
    }
}
