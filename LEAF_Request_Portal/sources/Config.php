<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class Config
{
    public $title;

    public $city;

    public $adPath; // Active directory path

    public static $uploadDir;    // Directory for user uploads
    // using backslashes (/), with trailing slash

    public static $orgchartPath; // HTTP Path to orgchart with no trailing slash

    public static $orgchartImportTags; // Import org chart groups if they match these tags

    public $descriptionID;     // indicator ID for description field

    public static $emailPrefix;  // Email prefix

    public static $emailCC;    // CCed for every email

    public static $emailBCC;      // BCCed for every email

    public $phonedbName;

    public $db;

    public function __construct()
    {
        $lp_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, 'national_leaf_launchpad');

        $vars = array(':site_path' => '/' . \PORTAL_PATH);
        $sql = 'SELECT site_uploads, portal_database, orgchart_path, orgchart_database
                FROM sites
                WHERE site_path= BINARY :site_path';

        $site_paths = $lp_db->prepared_query($sql, $vars)[0];

        $this->db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, $site_paths['portal_database']);

        $settings = new \Leaf\Setting($this->db);
        $settings = $settings->getSettings();

        $this->title = $settings['heading'];
        $this->city = $settings['subHeading'];
        $this->adPath = $this->parseJson($settings['adPath']);
        self::$uploadDir = $site_paths['site_uploads'];
        self::$orgchartPath = $site_paths['orgchart_path'];
        self::$orgchartImportTags = $this->parseJson($settings['orgchartImportTags']);
        $this->descriptionID = $settings['descriptionID'];
        self::$emailPrefix = $settings['requestLabel'];
        self::$emailCC = $this->parseJson($settings['emailCC']);
        self::$emailBCC = $this->parseJson($settings['emailBCC']);
        $this->phonedbName = $site_paths['orgchart_database'];
    }

    private function parseJson($data): string|array
    {
        $return_value = json_decode($data, true) ?? $data;

        return $return_value;
    }
}
