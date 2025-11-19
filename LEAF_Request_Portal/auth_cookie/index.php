<?php
use App\Leaf\Db;
use App\Leaf\Security;
/*
* As a work of the United States government, this project is in the public domain within the United States.
*/

/*
    Cookie Based Auth
    Date Created: April 30, 2019

*/

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

// For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https://' : 'http://';
$protocol = 'https://';

if (isset($_COOKIE['REMOTE_USER'])) {
    $defaultRedirect = $protocol . HTTP_HOST . dirname($_SERVER['PHP_SELF']) . '/.../';
    $redirect = Security::getSafeRedirectFromRequest(HTTP_HOST, $defaultRedirect, $protocol);

    $user = Security::decryptUser($_COOKIE['REMOTE_USER'], CIPHER_KEY);

    // see if user is valid
    $vars = array(':userName' => $user);
    $sql = 'SELECT *
            FROM `employee`
            WHERE `userName` = :userName
            AND `deleted` = 0';

    $res = $oc_db->prepared_query($sql, $vars);

    if (count($res) > 0) {
        $_SESSION['userID'] = $user;
        session_write_close();
        header('Location: ' . $redirect);
        exit();
    }

    // try searching through national database
    $globalDB = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
    $vars = array(':userName' => $user);
    $sql = 'SELECT `firstName`, `lastName`, `middleName`, `userName`,
                    `phoneticFirstName`, `phoneticLastName`, `domain`, `new_empUUID`,
                    `data`
            FROM `employee`
            LEFT JOIN `employee_data` USING (`empUID`)
            WHERE `userName` = :userName
            AND (`indicatorID` = 6
                OR `indicatorID` IS NULL)
            AND `deleted` = 0';

    $res = $globalDB->prepared_query($sql, $vars);

    if (count($res) > 0) {
        // add user to local DB
        $vars = array(':firstName' => $res[0]['firstName'],
                ':lastName' => $res[0]['lastName'],
                ':middleName' => $res[0]['middleName'],
                ':userName' => $res[0]['userName'],
                ':phoFirstName' => $res[0]['phoneticFirstName'],
                ':phoLastName' => $res[0]['phoneticLastName'],
                ':domain' => $res[0]['domain'],
                ':lastUpdated' => time(),
                ':new_empUUID' => $res[0]['new_empUUID'] );
        $sql = 'INSERT INTO `employee` (`firstName`, `lastName`, `middleName`,
                    `userName`, `phoneticFirstName`, `phoneticLastName`,
                    `domain`, `lastUpdated`, `new_empUUID`)
                VALUES (:firstName, :lastName, :middleName, :userName, :phoFirstName, :phoLastName, :domain, :lastUpdated, :new_empUUID)
                ON DUPLICATE KEY UPDATE `deleted` = 0';

        $oc_db->prepared_query($sql, $vars);

        $empUID = $oc_db->getLastInsertID();

        if ($empUID == 0) {
            $vars = array(':userName' => $res[0]['userName']);
            $sql = 'SELECT `empUID`
                    FROM `employee`
                    WHERE `userName` = :userName';

            $empUID = $oc_db->prepared_query($sql, $vars)[0]['empUID'];
        }

        // this is to get around if the data is not found in instances like service accounts
        if (!empty($res[0]['data'])) {
            $vars = array(':empUID' => $empUID,
                ':indicatorID' => 6,
                ':data' => $res[0]['data'],
                ':author' => 'viaLogin',
                ':timestamp' => time(),
            );
            $sql = 'INSERT INTO `employee_data` (`empUID`, `indicatorID`, `data`, `author`, `timestamp`)
                    VALUES (:empUID, :indicatorID, :data, :author, :timestamp)
                    ON DUPLICATE KEY UPDATE `data` = :data';

            $oc_db->prepared_query($sql, $vars);
        }

        // redirect as usual
        $_SESSION['userID'] = $res[0]['userName'];
        session_write_close();
        header('Location: ' . $redirect);
        exit();
    }

    header('Location: ' . $protocol . AUTH_URL . '/?r=' . base64_encode($_SERVER['REQUEST_URI']));
    exit();
}

header('Location: ' . $protocol . AUTH_URL . '/?r=' . base64_encode($_SERVER['REQUEST_URI']));
exit();
