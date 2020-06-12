<?php
ini_set('display_errors', 0);


define("LF", "\n");
include '../db_mysql.php';
include '../db_config.php';

$debug = false;
$db_config = new DB_Config();
mysql_connection($db_config->dbHost, $db_config->dbUser, $db_config->dbPass);
$database = $db_config->dbName;
// The find and replace strings.
$find = "Database Error";
$replace = "";
$loop = mysql_query("
SELECT
concat('UPDATE ',table_schema,'.',table_name, ' SET ',column_name, '=replace(',column_name,', ''{$find}'', ''{$replace}'');') AS s
FROM
information_schema.columns
WHERE
table_schema = '{$database}'")
or die ('Cant loop through dbfields: ' . mysql_error());

while ($query = mysql_fetch_assoc($loop))
{
mysql_query($query['s']);
}
