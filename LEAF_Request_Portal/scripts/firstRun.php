<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$vars = [];
$sql = 'SELECT `userID`
        FROM `users`
        WHERE `groupID`= 1
        AND `active` = 1';

$res = $db->prepared_query($sql, $vars);

if (empty($res)) {
    if (strlen(DATABASE_DB_ADMIN) > 0) {
        $vars = [':name' => DATABASE_DB_ADMIN];
        $sql = 'INSERT INTO `users` (`userID`, `groupID`, `backupID`)
                VALUES (:name, 1, "")';

        $res = $db->prepared_query($sql, $vars);

        echo 'Administrator added: ' . DATABASE_DB_ADMIN;
    } else {
        echo 'Please check administrator configuration.';
    }
} else {
    echo 'Administrator already set. Exiting.';
}
