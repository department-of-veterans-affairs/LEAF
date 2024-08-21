<?php
// require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';


if (!defined('DIRECTORY_HOST')) define('DIRECTORY_HOST', getenv('DATABASE_HOST'));
if (!defined('DIRECTORY_DB')) define('DIRECTORY_DB', getenv('DATABASE_DB_DIRECTORY'));
if (!defined('DIRECTORY_USER')) define('DIRECTORY_USER', getenv('DATABASE_USERNAME'));
if (!defined('DIRECTORY_PASS')) define('DIRECTORY_PASS', getenv('DATABASE_PASSWORD'));

$a = 0;
for($i = 0; $i < 1000000000; $i++) {
     $a += $i;
     echo "blue\n";
    //  for($j = 0; $j < 9999; $j++) {
    //     $db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');
    //     $res = $db->prepared_query("SELECT * FROM email_templates", array());
    //     echo "toga <br>";
    //     mysql_close();
    // }
}
echo "done";
?>