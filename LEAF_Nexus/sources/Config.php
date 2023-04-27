<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class Config
{
    public $title;

    public $city;

    public $adPath; // Active directory path

    public static $uploadDir;    // Directory for user uploads
    // using backslashes (/), with trailing slash

    public static $ERM_Sites; // HTTP Path to orgchart with no trailing slash

    public $oc_db;

    public $dbName;

    public function __construct()
    {
        $lp_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, 'national_leaf_launchpad');

        $vars = array(':site_path' => '/' . \PORTAL_PATH);
        $sql = 'SELECT site_uploads, orgchart_database
                FROM sites
                WHERE site_path= BINARY :site_path';

        $site_paths = $lp_db->prepared_query($sql, $vars)[0];

        $this->oc_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, $site_paths['orgchart_database']);

        $this->dbName = $site_paths['orgchart_database'];

        $oc_settings = new \Leaf\Setting($this->oc_db);
        $oc_settings = $oc_settings->getSettings();

        $this->title = $oc_settings['heading'];
        $this->city = $oc_settings['subheading'];
        $this->adPath = $this->parseJson($oc_settings['adPath']);
        self::$uploadDir = $site_paths['site_uploads'];
        self::$ERM_Sites = $this->parseJson($oc_settings['ERM_Sites']);
    }

    private function parseJson($data): string|array
    {
        $return_value = json_decode($data, true) ?? $data;

        return $return_value;
    }
}
