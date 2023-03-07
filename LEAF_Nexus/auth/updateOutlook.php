<?php
/************************
        Updates Outlook
        Author: Michael Gao (Michael.Gao@va.gov)
        Date: October 30, 2013

*/

require_once '../globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

$login->loginUser();
if(!$login->isLogin() || !$login->isInDB()) {
        echo 'Your computer login is not recognized. Is your account managed by IRM? If you are looking for the Resource Site demo, please visit: https://vhawasweb1.v05.med.va.gov/resource_demo/';
        exit;
}

if($_POST['CSRFToken'] == $_SESSION['CSRFToken']) {
        $employee = new Orgchart\Employee($db, $login);

        $phone = escapeshellarg($employee->getAllData($_POST['empUID'], 5)[5]['data']);

        $terms = explode(',', $config->adPath[0]);

        $userName = escapeshellarg($employee->lookupEmpUID($_POST['empUID'])[0]['userName']);
        $loginName = escapeshellarg($login->getUserID());
        // need admin access to edit other people's phone
        if($userName != $loginName) {
                $memberships = $login->getMembership();
                if(!isset($memberships['groupID'][1])
                && $memberships['groupID'][1] != 1) {
                        echo 'Admin required to edit Outlook';
                        exit();
                }
        }

        $userDN = exec("dsquery user -samid {$userName}");
        // discard multi-byte characters to workaround addslashes multi-byte vulnerability
        $sanitizedPassword = addslashes(mb_convert_encoding($_POST['NTPW'], 'ASCII'));
        $out = exec('dsmod user ' . $userDN . ' -tel '. $phone .' -u '.$loginName.' -p "'. $sanitizedPassword . '"');
        echo $out;
}
else {
        echo 'Invalid token.';
}
