<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$vars = array();
$res = $db->prepared_query('SELECT * FROM users WHERE groupID=1 AND `active` = 1', $vars);

if (count($res) == 0) {
    if (strlen(DATABASE_DB_ADMIN) > 0) {
        $vars = array(':name' => DATABASE_DB_ADMIN);
        $res = $db->prepared_query('INSERT INTO users (userID, groupID, backupID)
                                        VALUES (:name, 1, "")', $vars);
        echo 'Administrator added: ' . DATABASE_DB_ADMIN;
    } else {
        echo 'Please check administrator configuration.';
    }
} else {
    echo 'Administrator already set. Exiting.';
}
