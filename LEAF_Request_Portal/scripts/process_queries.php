<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

require_once $currDir.'/../globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');
$login->loginUser();

$form = new Portal\Form($db, $login);

// last process time
$vars = [
    //':lastProcess' => strtotime("30 minutes ago")
    ':lastProcess' => time()
];

$processQueryTotalSQL = 'SELECT id,userID,`url` FROM process_query WHERE lastProcess <= :lastProcess group by `url`';
$processQueryTotalRes = $db->prepared_query($processQueryTotalSQL, $vars);

if(!empty($processQueryTotalRes)){
    foreach($processQueryTotalRes as $processQuery){
        var_dump($processQuery);
        $returnedValue = $form->query($processQuery['url'],true);
var_export($returnedValue);
        // send email
    }
}
