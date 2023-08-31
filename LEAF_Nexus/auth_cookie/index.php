<?php
use App\Leaf\Db;
/*
* As a work of the United States government, this project is in the public domain within the United States.
*/

/*
    Cookie Based Auth
    Date Created: April 30, 2019

*/

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

// For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https://' : 'http://';
$protocol = 'https://';

if (isset($_COOKIE['REMOTE_USER']))
{
    $redirect = '';
    if (isset($_GET['r']))
    {
        $redirect = $protocol . HTTP_HOST . base64_decode($_GET['r']);
    }
    else
    {
        $redirect = $protocol . HTTP_HOST . dirname($_SERVER['PHP_SELF']) . '/../';
    }

    $user = decryptUser($_COOKIE['REMOTE_USER']);

    // see if user is valid
    $vars = array(':userName' => $user);
    $res = $oc_db->prepared_query('SELECT * FROM employee
                                 WHERE userName=:userName
                                  AND deleted=0', $vars);

    if (count($res) > 0)
    {
        $_SESSION['userID'] = $user;
        session_write_close();
        header('Location: ' . $redirect);
        exit();
    }
    else
    {
        // try searching through national database
        $globalDB = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
        $vars = array(':userName' => $user);
        $res = $globalDB->prepared_query('SELECT * FROM employee
                                          LEFT JOIN employee_data USING (empUID)
                                          WHERE userName=:userName
                                          AND indicatorID = 6
                                                  AND deleted=0', $vars);
        // add user to local DB
        if (count($res) > 0)
        {
            $vars = array(':firstName' => $res[0]['firstName'],
                    ':lastName' => $res[0]['lastName'],
                    ':middleName' => $res[0]['middleName'],
                    ':userName' => $res[0]['userName'],
                    ':phoFirstName' => $res[0]['phoneticFirstName'],
                    ':phoLastName' => $res[0]['phoneticLastName'],
                    ':domain' => $res[0]['domain'],
                    ':lastUpdated' => time(),
                    ':new_empUUID' => $res[0]['new_empUUID'] );
            $oc_db->prepared_query('INSERT INTO employee (firstName, lastName, middleName, userName, phoneticFirstName, phoneticLastName, domain, lastUpdated, new_empUUID)
                                  VALUES (:firstName, :lastName, :middleName, :userName, :phoFirstName, :phoLastName, :domain, :lastUpdated, :new_empUUID)
                                  ON DUPLICATE KEY UPDATE deleted=0', $vars);

            $empUID = $oc_db->getLastInsertID();

            if ($empUID == 0)
            {
                $vars = array(':userName' => $res[0]['userName']);
                $empUID = $oc_db->prepared_query('SELECT empUID FROM employee
                                                            WHERE userName=:userName', $vars)[0]['empUID'];
            }

            $vars = array(':empUID' => $empUID,
                    ':indicatorID' => 6,
                    ':data' => $res[0]['data'],
                    ':author' => 'viaLogin',
                    ':timestamp' => time(),
            );
            $oc_db->prepared_query('INSERT INTO employee_data (empUID, indicatorID, data, author, timestamp)
                                            VALUES (:empUID, :indicatorID, :data, :author, :timestamp)
                                            ON DUPLICATE KEY UPDATE data=:data', $vars);

            // redirect as usual
            $_SESSION['userID'] = $res[0]['userName'];
            session_write_close();
            header('Location: ' . $redirect);
            exit();
        }
        else
        {
            header('Location: ' . $protocol . AUTH_URL . '/?r=' . base64_encode($_SERVER['REQUEST_URI']));
        }
    }
}else{
    header('Location: ' . $protocol . AUTH_URL . '/?r=' . base64_encode($_SERVER['REQUEST_URI']));
}


function decryptUser($src){
  $corrected = preg_replace("[^0-9a-fA-F]", "", $src);
  $crypted_token = pack("H".strlen($corrected), $corrected);

  list($crypted_token, $enc_iv) = explode("::", $crypted_token);
  $cipher_method = 'aes-128-ctr';
  $enc_key = openssl_digest(CIPHER_KEY, 'SHA256', TRUE);
  $token = openssl_decrypt($crypted_token, $cipher_method, $enc_key, 0, hex2bin($enc_iv));
  unset($crypted_token, $cipher_method, $enc_key, $enc_iv);

  return $token;
}