<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date: September 17, 2015

*/

class System
{
    public $siteRoot = '';

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';

        if (!class_exists('XSSHelpers'))
        {
            include_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
        }
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

        if (array_search($_POST['timeZone'], DateTimeZone::listIdentifiers(DateTimeZone::PER_COUNTRY, 'US')) === false)
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

    public function newReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
                || $template == 'example'
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
                || $template == 'example')
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

        if (array_search($template, $list) !== false)
        {
            file_put_contents("../templates/reports/{$template}", $_POST['file']);
        }
    }

    public function removeReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
                || $template == 'example')
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
}
