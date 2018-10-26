<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include_once dirname(__FILE__) . '/../db_mysql.php';
include_once dirname(__FILE__) . '/../db_config.php';
include_once dirname(__FILE__) . '/../../libs/php-commons/FileHasher.php';

$db_config = new DB_Config();
$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : './UPLOADS/';

//set working directory to request portal directory
chdir(realpath(dirname(__FILE__).'/../'));

$fileHasher = new FileHasher($db);

//Get all filenames from database
$result = $db->query("SELECT data.*
                        FROM indicators ind
                        right join data using (indicatorID)
                        where ind.format in ('image','fileupload')
                        and data.data != '';
                        ");

foreach ($result as $data)
{
    //some data may have multiple files, separated by a newline
    $fileNamesArray = explode("\n", $data['data']);
    foreach ($fileNamesArray as $fileName)
    {
        $fileNameInFolder = "{$data['recordID']}_{$data['indicatorID']}_{$data['series']}_{$fileName}";
        $newFileName = $fileHasher->portalFileHash($data['recordID'], $data['indicatorID'], $data['series'], $fileName);
        echo $uploadDir . $fileNameInFolder . " >> " . $uploadDir . $newFileName."\r\n";
        rename($uploadDir . $fileNameInFolder, $uploadDir . $newFileName);
    }
}
