<?php
namespace App\Leaf;
require_once '../html/app/Leaf/Db.php';


if (!defined('DIRECTORY_HOST')) define('DIRECTORY_HOST', getenv('DATABASE_HOST'));
if (!defined('DIRECTORY_DB')) define('DIRECTORY_DB', getenv('DATABASE_DB_DIRECTORY'));
if (!defined('DIRECTORY_USER')) define('DIRECTORY_USER', getenv('DATABASE_USERNAME'));
if (!defined('DIRECTORY_PASS')) define('DIRECTORY_PASS', getenv('DATABASE_PASSWORD'));




function pime($accuracy){
    $pi = 4; $top = 4; $bot = 3; $minus = TRUE;
    for($i = 0; $i < $accuracy; $i++)
    {
        $pi += ( $minus ? -($top/$bot) : ($top/$bot) );
        $minus = ( $minus ? FALSE : TRUE);
        $bot += 2;
    }
    return $pi;
}


$a = 0;
$ut = 100000;
$jj = 9999;
for($i = 0; $i < $ut; $i++) {
    $a += $i;
    echo "a = $a \n";
    $blue = sqrt($a);      
    echo "blue = $blue\n";
    $pie = pime($i);
    echo "pie = $pie\n";    
    for($j = 0; $j < $jj; $j++) {
        $db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');
        $res = $db->prepared_query("SELECT * FROM email_templates", array());
        echo "toga $i - $j\n";
        $db->__destruct();
    }
    echo "sql test done number: $a \n";
}
echo "done";
?>