<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date: September 17, 2015

*/

namespace Orgchart;

use App\Leaf\Logger\DataActionLogger;
use App\Leaf\XSSHelpers;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;

class System
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $this->dataActionLogger = new DataActionLogger($db, $login);

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
    }

    /**
     * Get the current database version
     *
     * @return string the current database version
     */
    public function getDatabaseVersion()
    {
        $version = $this->db->prepared_query('SELECT data FROM settings WHERE setting = "dbVersion"', array());
        if (count($version) > 0 && $version[0]['data'] !== null)
        {
            return $version[0]['data'];
        }

        return 'unknown';
    }

    public function setHeading($heading)
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $in = preg_replace('/[^\040-\176]/', '', XSSHelpers::sanitizeHTML($heading));
        $vars = array(':input' => $in);

        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="heading"', $vars);

        return 1;
    }

    public function setSubHeading($subHeading)
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $in = preg_replace('/[^\040-\176]/', '', XSSHelpers::sanitizeHTML($subHeading));
        $vars = array(':input' => $in);

        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="subheading"', $vars);

        return 1;
    }

    public function setTimeZone()
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $tz_additional = array(
            "America/Puerto_Rico",
            "Pacific/Guam",
            "Pacific/Saipan",
            "Pacific/Pago_Pago",
            "Asia/Manila",
        );
        $tzones = array_merge(\DateTimeZone::listIdentifiers(\DateTimeZone::PER_COUNTRY, 'US'), $tz_additional);
        if (array_search($_POST['timeZone'], $tzones) === false)
        {
            return 'Invalid timezone';
        }

        $vars = array(':input' => $_POST['timeZone']);

        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="timeZone"', $vars);

        return 1;
    }

    public function getReportTemplateList()
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $list = scandir('../templates/reports/');
        $out = array();
        foreach ($list as $item)
        {
            if (preg_match('/.tpl$/', $item))
            {
                $out[] = $item;
            }
        }

        return $out;
    }

    private function isReservedFilename($file)
    {
        if($file == 'example'
            || substr($file, 0, 5) == 'LEAF_'
        ) {
            return true;
        }
        return false;
    }

    public function newReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
                || $this->isReservedFilename($template)
                || $template == '')
        {
            return 'Invalid or reserved name.';
        }
        $template .= '.tpl';
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) === false)
        {
            copy('../templates/reports/example.tpl', "../templates/reports/{$template}");
        }
        else
        {
            return 'File already exists';
        }

        return 'CreateOK';
    }

    public function getReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in)
        {
            return 0;
        }
        $template .= '.tpl';
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        $data = array();
        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/reports/{$template}"))
            {
                $data['file'] = file_get_contents("../templates/reports/{$template}");
            }
        }

        return $data;
    }

    public function setReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
                || $this->isReservedFilename($in))
        {
            return 'Cannot modify reserved templates';
        }
        $template .= '.tpl';
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) !== false)
        {
            file_put_contents("../templates/reports/{$template}", $_POST['file']);
        }
    }

    public function removeReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
                || $this->isReservedFilename($template))
        {
            return 'Cannot remove reserved templates';
        }
        $template .= '.tpl';
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/reports/{$template}"))
            {
                return unlink("../templates/reports/{$template}");
            }
        }
    }

    /**
     * Checks for admin priviledges and runs batch refresh local orgchart employee
     *
     * @return $ret returns last echo from script
     */
    public function refreshOrgchartEmployees()
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            return 'Admin access required';
        }

        header('Cache-Control: no-cache');
        exec('php ../scripts/refreshOrgchartEmployees.php &', $output);

        $ret = $output[count($output) - 1];

        return $ret;
    }

    /**
     * Get primary admin.
     *
     * @return array array with primary admin's info
     */
    public function getPrimaryAdmin(): array
    {
        $strSQL = "SELECT `data` FROM `settings` WHERE `setting` = 'primaryAdmin'";
        $primaryAdminRes = $this->db->query($strSQL);

        if(count($primaryAdminRes) > 0)
        {
            $employee = new Employee($this->db, $this->login);
            $user = $employee->lookupLogin($primaryAdminRes[0]['data']);
        }

        return isset($user[0]) ? $user[0] : [];
    }

    /**
     * Set primary admin.
     *
     * @return array array with response array
     */
    public function setPrimaryAdmin(): array
    {
        $userID = XSSHelpers::xscrub($_POST['userID']);

        //check if user is system admin
        $employee = new Employee($this->db, $this->login);
        $user = $employee->lookupLogin($userID);

        $sqlVars = array(':empUID' => $user[0]['empUID']);
        $strSQL = "SELECT `empUID` FROM `relation_group_employee`".
                    "WHERE `groupID` = 1 AND empUID = :empUID";
        $res = $this->db->prepared_query($strSQL, $sqlVars);

        $resultArray = array('success' => false, 'response' => $res);

        if(count($res) > 0)
        {
            $sqlVars = array(':userID' => $user[0]['userName']);
            $strSQL = "INSERT INTO `settings` (`setting`, `data`) VALUES ('primaryAdmin', :userID) ".
                        "ON DUPLICATE KEY UPDATE `data` = :userID";
            $this->db->prepared_query($strSQL, $sqlVars);

            $resultArray = array('success' => true, 'response' => $res);

            $primary = $this->getPrimaryAdmin();

            $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::PRIMARY_ADMIN, [
                new LogItem("settings", "setting", 'primaryAdmin'),
                new LogItem("settings", "data", $primary["empUID"], $primary["firstName"].' '.$primary["lastName"]),
            ]);
        }

        return $resultArray;
    }

    /**
     * Unset primary admin.
     *
     * @return array array with query response
     */
    public function unsetPrimaryAdmin(): array
    {
        $primary = $this->getPrimaryAdmin();

        $strSQL = "DELETE FROM `settings` WHERE `setting` = 'primaryAdmin'";
        $result = $this->db->query($strSQL);

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::PRIMARY_ADMIN, [
            new LogItem("users", "primary_admin", 1),
            new LogItem("users", "userID", $primary["empUID"], $primary["firstName"].' '.$primary["lastName"])
        ]);

        return $result;
    }
}
