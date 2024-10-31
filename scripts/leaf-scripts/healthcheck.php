<?php

/* this health check will ensure that php is up and running by the very
    of the fact the page gets rendered.

    It will also get a simple query from the database to ensure that it
    is up and running.

    */

if (!defined('DIRECTORY_HOST')) define('DIRECTORY_HOST', getenv('DATABASE_HOST'));
if (!defined('DIRECTORY_DB')) define('DIRECTORY_DB', getenv('DATABASE_DB_DIRECTORY'));
if (!defined('DIRECTORY_USER')) define('DIRECTORY_USER', getenv('DATABASE_USERNAME'));
if (!defined('DIRECTORY_PASS')) define('DIRECTORY_PASS', getenv('DATABASE_PASSWORD'));

require_once '/var/www/html/app/Leaf/Db.php';

$db = new \App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

// get something simple from the db to return
$sql = 'show status';
$result = $db->query($sql);

echo $result['uptime'];
