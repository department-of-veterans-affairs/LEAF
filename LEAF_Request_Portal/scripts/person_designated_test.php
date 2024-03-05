<?php
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL ^ E_WARNING);

$currDir = dirname(__FILE__);
require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';
// copied from FormWorkflow.php just to get us moved along.
$protocol = 'https';

// userid is like VTRQEUVENESSA
$userID = "VTRQEUVENESSA";
$login->loginUser($userID);

$email = new Portal\Email();

$recordID = 7570;
$ret = $email->attachApproversAndEmailTest($recordID,Portal\Email::AUTOMATED_EMAIL_REMINDER,$login);
var_dump($ret);